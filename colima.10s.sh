#!/usr/bin/env bash
# <bitbar.title>Lima Control</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Bendik Solheim</bitbar.author>
# <bitbar.author.github>bendiksolheim</bitbar.author.github>
# <bitbar.desc>Control your lima instances and docker containers inside them.</bitbar.desc>
# <bitbar.dependencies>lima,docker</bitbar.dependencies>
# <bitbar.droptypes>Supported UTI's for dropping things on menu bar</bitbar.droptypes>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

export PATH="/usr/local/bin:${PATH}"

DOCKER_COMMAND=$(command -v docker)
LIMACTL_COMMAND=$(command -v limactl)
DOCKER_PS_FORMAT="table {{.Names}}|{{.Status}}|{{.ID}}"

echo ":mustache:"
echo "---"

limactl list | tail -n +2 | while read line; do
  vm_name=$(echo "$line" | awk '{ print $1 }')
  vm_status=$(echo "$line" | awk '{ print $2}')
  vm_cpus=$(echo "$line" | awk '{ print $5 }')
  vm_ram=$(echo "$line" | awk '{ print $6 }')
  vm_disk=$(echo "$line" | awk '{ print $7 }')

  echo ":server.rack: $vm_name"
  echo "--Status: $vm_status"
  echo "--:cpu: $vm_cpus    :memorychip: $vm_ram    :internaldrive: $vm_disk"
  echo "-----"

  echo "--Actions"
  echo "----Start | shell=$LIMACTL_COMMAND param1=start param2=$vm_name refresh=true terminal=false"
  echo "----Stop | shell=$LIMACTL_COMMAND param1=stop param2=$vm_name refresh=true terminal=false"
  echo "----Delete | shell=$LIMACTL_COMMAND param1=delete param2=$vm_name refresh=true terminal=false"

  echo "-----"

  docker --context "$vm_name" ps -a --format "$DOCKER_PS_FORMAT" | tail -n +2 | while read container; do
    container_name=$(echo $container | awk -F'|' '{ print $1 }')
    container_status=$(echo $container | awk -F'|' '{ print $2 }')
    container_id=$(echo $container | awk -F'|' '{ print $3 }')

    if [ "$(docker --context $vm_name inspect -f '{{.State.Running}}' $container_name)" = "true" ]; then
        echo "--:cube.fill: $container_name | sfcolor=green"
        echo "----Status: $container_status"
        echo "-------"
        echo "----:stop.fill: Stop | shell=$DOCKER_COMMAND param1='--context' param2=$vm_name param3=stop param4=$container_id refresh=true"
    else
        echo "--:cube.fill: $container_name | sfcolor=pink"
        echo "----Status: $container_status"
        echo "-------"
        echo "----:play.fill: Start | shell=$DOCKER_COMMAND param1='--context' param2=$vm_name param3=start param4=$container_id refresh=true"
        echo "----:trash: Remove | shell=$DOCKER_COMMAND param1='--context' param2=$vm_name param3=rm param4=$container_id refresh=true"
    fi
  done
done
