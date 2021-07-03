


# Defined interactively
function fish_prompt
	#Save the return status of the previous command
	set -l last_pipestatus $pipestatus

	set -q __fish_git_prompt_showupstream
		or set -g __fish_git_prompt_showupstream auto

	set -q __fp_maximum_screen_width 
		or set -g __fp_maximum_screen_width (tput cols)
	set -q __fp_maximum_path_width 
		or set -g __fp_maximum_path_width (math $__fp_maximum_screen_width / 3)


	set -g __fp_info_for_count ""
	function _nim_prompt_wrapper_left
		set_color normal
		set_color $argv[1] -b $argv[2]
		echo -n $argv[4]
		set_color $argv[2] -b $argv[3]
		echo -n $argv[5]
		set_color normal
		set __fp_info_for_count $__fp_info_for_count$argv[4]$argv[5]
	end

	function fish_mode_prompt
	end

	if test "$fish_key_bindings" = fish_vi_key_bindings 
		or test "$fish_key_bindings" = fish_hybrid_key_bindings
		set -g mode 
		switch $fish_bind_mode
			case default
				set mode brred
			case insert
				set mode brblack
			case replace_one
				set mode white
			case replace
				set mode white
			case visual
				set mode yellow
		end
	end
	_nim_prompt_wrapper_left green $mode green '' ''

#PATH
	set -l path (string replace -r '^/home/'"$USER"'($|/)' '~$1' $PWD)
	set -q __fp_path_for_verification
		or set -g __fp_path_for_verification ""
	if test $__fp_path_for_verification != $path
		if [ (string length $path) -lt $__fp_maximum_path_width ]
			set -g __fp_path_for_printing $path
		else 
			set -g __fp_path_for_printing (prompt_pwd)
		end
		set __fp_path_for_verification $path
	end

	_nim_prompt_wrapper_left brblack green yellow ' '$__fp_path_for_printing' ' ''

	#

# git
	set -g __fp_gitinfo_for_printing (fish_git_prompt | string trim -c ' ()')

	set -q __fp_gitinfo_for_count; or set -g __fp_gitinfo_for_count 0
	if test (math $__fp_gitinfo_for_count % 1) = 0
		set __fp_gitinfo_for_printing (fish_git_prompt | string trim -c ' ()')

		set -g __fp_maximum_screen_width (tput cols)
		set -g __fp_maximum_path_width (math $__fp_maximum_screen_width / 3)
	end
	set __fp_gitinfo_for_count (math $__fp_gitinfo_for_count + 1)

	if test -n "$__fp_gitinfo_for_printing"
		_nim_prompt_wrapper_left purple yellow brblack ' '$__fp_gitinfo_for_printing' ' ''
	else
		_nim_prompt_wrapper_left purple yellow brblack ''                          ''
	end

########################################################################
#error_code
	if test "$last_pipestatus" != 0
		and test "$last_pipestatus" != 141
		_nim_prompt_wrapper_left red brblack normal ' '$last_pipestatus' ' ' '
	else
		_nim_prompt_wrapper_left red brblack normal ""                     ' '
	end

########################################################################





	set __fp_info_for_count $__fp_info_for_count"                                 " #<<<<

# Vi-mode
# The default mode prompt would be prefixed, which ruins our alignment.
end




#function fish_right_prompt
#
#	function _nim_prompt_wrapper_right_aux
#		set_color normal
#		set_color $argv[2] -b $argv[3]
#		echo -n $argv[5]
#		set_color $argv[1] -b $argv[2]
#		echo -n $argv[4]
#		set_color normal
#	end
#
#	set -g _nim_prompt_wrapper_right_count 1
#	function _nim_prompt_wrapper_right
#		if test (math (string length "$__fp_info_for_count") + (string length $argv[1])) -lt $__fp_maximum_screen_width
#			if test (math $_nim_prompt_wrapper_right_count % 2) = 1
#				_nim_prompt_wrapper_right_aux brblack white   brblack ' '$argv[1]' ' $argv[2]
#			else
#				_nim_prompt_wrapper_right_aux white   brblack white   ' '$argv[1]' ' $argv[2]
#			end
#			set __fp_info_for_count $__fp_info_for_count$argv[1]
#			set _nim_prompt_wrapper_right_count (math $_nim_prompt_wrapper_right_count + 1)
#		end
#	end
#
## Vi-mode
## The default mode prompt would be prefixed, which ruins our alignment.
#	function fish_mode_prompt
#	end
#
#	if test "$fish_key_bindings" = fish_vi_key_bindings 
#		or test "$fish_key_bindings" = fish_hybrid_key_bindings
#		set -l mode 
#		switch $fish_bind_mode
#			case default
#				set mode (set_color white)NORMAL
#			case insert
#				set mode (set_color white)INSERT
#			case replace_one
#				set mode (set_color white)REPONE
#			case replace
#				set mode (set_color white)REPALL
#			case visual
#				set mode (set_color white)VISUAL
#		end
#		_nim_prompt_wrapper_right_aux white brblack normal " $mode " ''
#		set __fp_info_for_count $__fp_info_for_count" $mode "
#	end
#			
#
#
#
#
#########################################################################
#	
#	_nim_prompt_wrapper_right (date '+%H:%M:%S')        ''
#	_nim_prompt_wrapper_right "$USER@"(prompt_hostname) ''
#
#########################################################################
#
#
#
#
#	if test (math $_nim_prompt_wrapper_right_count % 2) = 1
#		_nim_prompt_wrapper_right_aux brblack white   brblack "" ''
#	else
#		_nim_prompt_wrapper_right_aux white   brblack white   "" ''
#	end
#end
#
#
##function fish_command_not_found
##    echo -n 'did not find command: ' 
##    set_color normal
##    set_color red
##    echo $argv[1]
##end

