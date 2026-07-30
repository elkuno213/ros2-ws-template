#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit 2>/dev/null || true

readonly WORKSPACE_DIR="/workspaces/ros2-ws"
readonly WORKSPACES_DIR="/workspaces"
readonly ROS_USER="ros"
readonly DEFAULT_UID="1000"
readonly DEFAULT_GID="1000"

main() {
  local current_uid
  current_uid="$(id -u)"

  # The first container process may start as root so it can remap the ros user
  # to the bind-mounted workspace owner before dropping privileges.
  if [[ "${current_uid}" == "0" ]]; then
    reconcile_as_root "$@"
  fi

  local current_user
  current_user="$(id -un 2>/dev/null || true)"

  # After privilege drop, only the configured non-root user should run commands.
  if [[ "${current_user}" != "${ROS_USER}" ]]; then
    printf 'entrypoint.sh must run as root or %s; current uid is %s\n' \
      "${ROS_USER}" "${current_uid}" >&2
    exit 1
  fi

  reconcile_as_ros "$@"
}

detect_target_ids() {
  local target_uid="${DEFAULT_UID}"
  local target_gid="${DEFAULT_GID}"

  mkdir -p -- "${WORKSPACE_DIR}"

  # Prefer the mounted workspace owner. This keeps generated build artifacts
  # writable from both the host and the container.
  local workspace_uid
  local workspace_gid
  workspace_uid="$(stat -c '%u' -- "${WORKSPACE_DIR}")"
  workspace_gid="$(stat -c '%g' -- "${WORKSPACE_DIR}")"

  if [[ "${workspace_uid}" != "0" ]]; then
    target_uid="${workspace_uid}"
  fi

  if [[ "${workspace_gid}" != "0" ]]; then
    target_gid="${workspace_gid}"
  fi

  printf '%s:%s\n' "${target_uid}" "${target_gid}"
}

reconcile_as_root() {
  local target_uid
  local target_gid
  IFS=: read -r target_uid target_gid < <(detect_target_ids)

  # Root can safely adjust /etc/passwd and /etc/group before switching users.
  ensure_group_id "${target_gid}"
  ensure_user_id "${target_uid}"

  local ros_group
  ros_group="$(id -gn "${ROS_USER}")"

  chown -R -- "${ROS_USER}:${ros_group}" "/home/${ROS_USER}" "${WORKSPACES_DIR}"

  exec gosu "${ROS_USER}" "$@"
}

reconcile_as_ros() {
  sudo mkdir -p -- "${WORKSPACE_DIR}"

  local target_uid
  local target_gid
  IFS=: read -r target_uid target_gid < <(detect_target_ids)

  local current_uid
  local current_gid
  current_uid="$(id -u "${ROS_USER}")"
  current_gid="$(id -g "${ROS_USER}")"

  if [[ "${current_uid}" != "${target_uid}" || "${current_gid}" != "${target_gid}" ]]; then
    # Re-exec through sudo before usermod changes the UID of the running shell.
    exec sudo -E -- "$0" "$@"
  fi

  local ros_group
  ros_group="$(id -gn "${ROS_USER}")"

  sudo chown -R -- "${ROS_USER}:${ros_group}" "/home/${ROS_USER}" "${WORKSPACES_DIR}"

  exec "$@"
}

ensure_group_id() {
  local target_gid="$1"
  local current_gid
  current_gid="$(id -g "${ROS_USER}")"

  if [[ "${current_gid}" == "${target_gid}" ]]; then
    return 0
  fi

  local existing_group
  existing_group="$(getent group "${target_gid}" | cut -d: -f1 || true)"

  # If another group already owns the target GID, make ros use that group
  # instead of trying to take over an occupied GID.
  if [[ -n "${existing_group}" && "${existing_group}" != "${ROS_USER}" ]]; then
    usermod --gid "${target_gid}" "${ROS_USER}"
    return 0
  fi

  groupmod --gid "${target_gid}" "${ROS_USER}"
}

ensure_user_id() {
  local target_uid="$1"
  local current_uid
  current_uid="$(id -u "${ROS_USER}")"

  if [[ "${current_uid}" == "${target_uid}" ]]; then
    return 0
  fi

  local existing_user
  existing_user="$(getent passwd "${target_uid}" | cut -d: -f1 || true)"

  # Do not steal an existing UID from another user in the image.
  if [[ -n "${existing_user}" && "${existing_user}" != "${ROS_USER}" ]]; then
    printf 'uid %s is already used by %s; keeping %s as uid %s\n' \
      "${target_uid}" "${existing_user}" "${ROS_USER}" "${current_uid}" >&2
    return 0
  fi

  usermod --uid "${target_uid}" "${ROS_USER}"
}

main "$@"
