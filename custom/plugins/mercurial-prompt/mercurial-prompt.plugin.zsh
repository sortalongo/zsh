# Updates hg root
function update_hg_root() {
  local hgpath=$(pwd)
  while [[ $hgpath != "/" && ( ! -d "$hgpath/.hg" ) ]]; do
    local v="$hgpath/.."
    hgpath=$v:A
  done

  if [[ $hgpath != "/" ]]; then
    HG_ROOT=$hgpath
  else
    HG_ROOT="" # hg repository not found
  fi
}

function preexec_update_hg_root() {
    case "$2" in
        hg*)
        __EXECUTED_HG_COMMAND=1
        ;;
    esac
}

function precmd_update_hg_root() {
    if [ -n "$__EXECUTED_HG_COMMAND" ]; then
        update_hg_root
        unset __EXECUTED_HG_COMMAND
    fi
}

# Will update hg root every time user changes dir.
# This approach fast but doesn't work with some corner
# cases:
# - user deletes .hg  directory.

# Only one function
if  [[ ${chpwd_functions[(r)update_hg_root]} != update_hg_root ]]; then
  chpwd_functions+=(update_hg_root)
fi

if [[ ${precmd_functions[(r)precmd_update_hg_root]} != precmd_update_hg_root ]]; then
  precmd_functions+=(precmd_update_hg_root)
fi

if [[ ${preexec_functions[(r)preexec_update_hg_root]} != preexec_update_hg_root ]]; then
  preexec_functions+=(preexec_update_hg_root)
fi

function hg_branch() {
    if [[ -n $HG_ROOT ]]; then
        local branch=$(cat "$HG_ROOT/.hg/branch" 2> /dev/null)
        if [[ -n $branch ]]; then
          echo -n $branch
        else
          # After creation of empty repository branch technicaly
          # is `default`. But .hg/branch is not created until
          # hg up -C will be run.
          echo -n "default"
        fi
    fi
}

function hg_prompt_info() {
    if [[ -n $HG_ROOT ]]; then
        # Relies on agnoster theme fuction.
        prompt_segment green black "☿"
    fi
}
