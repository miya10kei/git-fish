function git_fish -a sub_command
  switch $sub_command
    case 'cd'
      __git_fish_cd
    case 'erase' 'er'
      __git_fish_erase
    case 'select' 'sl'
      __git_fish_select
    case 'commit' 'cm'
      eval "__git_fish_git $argv[1..-2] \"'$argv[-1]'\""
    case '*'
      eval "__git_fish_git $argv"
  end
end

# --------------------------------------------------
# sub command
# --------------------------------------------------
function __git_fish_cd
  set -l selected_git_directory (ghq list | fzf)

  if test -z "$selected_git_directory"
    return
  end

  eval "cd (ghq root)/$selected_git_directory"
end

function __git_fish_erase
  set -l current_branch (__git_fish_git branch --show-current)
  set -l local_branches (__git_fish_git branch --format="%(refname:short)")
  set -l branches (__git_fish_subtract_array "$local_branches" "$current_branch")

  if test -z "$branches"
    echo 'There aren\'t selectable branches.'
    return
  end

  set -l selected_branches (__git_fish_git_fish_echo_array $branches | fzf --multi)

  if test -z "$selected_branches"
    return
  end

  for branch in $selected_branches
    __git_fish_git branch -D $branch
  end
end

function __git_fish_select
  set -l current_branch (__git_fish_git branch --show-current)
  set -l local_branches (__git_fish_git branch --format='%(refname:short)')
  set -l remote_branches (__git_fish_git branch --format='%(refname:short)' -r)
  set -l remotes (__git_fish_git remote)
  set -l excluded_remote_branches (__git_fish_cross_join_array "/" "$remotes" "$local_branches")
  set -l branches (__git_fish_subtract_array "$local_branches" "$current_branch") \
                  (__git_fish_subtract_array "$remote_branches" "$excluded_remote_branches")

  if test -z "$branches"
    echo 'There aren\'t selectable branches.'
    return
  end

  set -l selected_branch (__git_fish_git_fish_echo_array $branches | fzf)

  if test -z "$selected_branch"
    return
  end

  set -l is_remote_branch (__git_fish_is_exit_in_array $selected_branch "$remote_branches")
  if $is_remote_branch
    set -l new_branch (string replace -r '\w+/' '' $selected_branch)
    eval "__git_fish_git checkout -b $new_branch $selected_branch"
  else
    eval "__git_fish_git checkout $selected_branch"
  end
end


# --------------------------------------------------
# private function
# --------------------------------------------------
function __git_fish_cross_join_array -a delimiter -a array_str1 -a array_str2
  set -l array1 (__git_fish_string_to_array $array_str1)
  set -l array2 (__git_fish_string_to_array $array_str2)

  for left in $array1
    for right in $array2
      echo "$left$delimiter$right"
    end
  end
end

function __git_fish_string_to_array -a str
  string split ' ' $str
end

function __git_fish_subtract_array -a array_str1 -a array_str2
  set -l array1 (__git_fish_string_to_array $array_str1)
  set -l array2 (__git_fish_string_to_array $array_str2)

  for left in $array1
    set -l founded false
    for right in $array2
      if test $left = $right
        set founded true
        continue
      end
    end
    if not $founded
      echo $left
    end
  end
end

function __git_fish_git_fish_echo_array
  string join \n $argv
end

function __git_fish_is_exit_in_array -a key -a array_str
  set -l array (__git_fish_string_to_array $array_str)

  for element in $array
    if test "$key" = "$element"
      echo true
      return
    end
  end
  echo false
end

function __git_fish_git
  command git $argv[1..-2] $argv[-1]
end
