#!/bin/bash -eux

# set the agent version to be installed
AGENT_VERSION="3446-20171214053739"

echo "==> Generating chef json for first OpsWorks run"
TMPDIR=$(mktemp -d) && trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p $TMPDIR/cookbooks

# Create a base json file to execute some default recipes
cat <<EOT > $TMPDIR/dna.json
{
  "opsworks_initial_setup": {
    "swapfile_instancetypes": null
  },
  "opsworks_custom_cookbooks": {
    "enabled": true,
    "scm": {
      "repository": "$TMPDIR/cookbooks"
    },
    "manage_berkshelf": true,
    "recipes": [
      "recipe[opsworks_initial_setup]",
      "recipe[ssh_host_keys]",
      "recipe[ssh_users]",
      "recipe[dependencies]",
      "recipe[deploy::default]",
      "recipe[agent_version]",
      "recipe[opsworks_stack_state_sync]",
      "recipe[opsworks_cleanup]"
    ]
  }
}
EOT

cat <<EOT >> $TMPDIR/cookbooks/Berksfile

EOT

echo "==> Installing and running OpsWorks agent"
chmod +x /tmp/opsworks/opsworks
env OPSWORKS_AGENT_VERSION="$AGENT_VERSION" /tmp/opsworks/opsworks $TMPDIR/dna.json
