#! /bin/sh

script_root=$(cd $(dirname $0) && pwd)

pattern_root=${script_root}
test_root=${pattern_root}/serverspec
spec_dir=${test_root}/spec
log_dir=${pattern_root}/logs
LOG_FILE=${log_dir}/event-handler.log

if [ ! -d ${log_dir} ]; then
  mkdir ${log_dir}
fi

if [ "${CONSUL_SECRET_KEY}" == "" ]; then
  CONSUL_SECRET_KEY=$(cat /etc/consul.d/default.json | jq -r .acl_master_token)
fi

CONSUL_SECRET_KEY_ENCODED=$(python -c "import urllib; print urllib.quote('${CONSUL_SECRET_KEY}')")

app_info=$(curl -s http://localhost:8500/v1/kv/cloudconductor/parameters?raw\&token=${CONSUL_SECRET_KEY_ENCODED} | jq .cloudconductor.applications)

run() {
  local e E T
  [[ ! "$-" =~ e ]] || e=1
  [[ ! "$-" =~ E ]] || E=1
  [[ ! "$-" =~ T ]] || T=1

  set +e
  set +E
  set +T

  output="$("$@" 2>&1)"
  status="$?"
  local oldIFS=$IFS
  IFS=$'\n' lines=($output)

  IFS=$oldIFS
  [ -z "$e" ] || set -e
  [ -z "$E" ] || set -E
  [ -z "$T" ] || set -T
}

function log() {
  level="$1"
  message="$2"
  echo "[`date +'%Y-%m-%dT%H:%M:%S'`] ${level}: ${message}" >> ${LOG_FILE}
}

log_info() {
  message="$1"
  log "INFO" "${message}"
}

log_error() {
  message="$1"
  log "ERROR" "${message}"
}

execute_serverspec() {
  local roles=($(echo $1 | tr -s ',' ' '))
  local event=$2

  for role in ${roles[@]}; do
    spec_file=${spec_dir}/${role}/${role}_${event}_spec.rb
    if [ -f "${spec_file}" ]; then
      log_info "execute serverspec with [${spec_file}]"

      run sh -c "cd ${test_root}; rake spec['${role}','${event}']"
      if [ ${status} -ne 0 ]; then
        log_error 'finished abnormally.'
        log_error "${output}"

        echo "${output}" >&2
        return $status
      else
        log_info 'finished successfully.'
      fi
    else
      log_info "spec file [${spec_file}] does not exist. skipped."
    fi
  done
}

roles=all,$1

if [ "$1" == "" ]; then
  roles=all,${ROLE}
fi

execute_serverspec ${roles} configure || exit $?

if [ "${app_info}" != "null" ];then
  execute_serverspec ${roles} deploy || exit $?
fi
