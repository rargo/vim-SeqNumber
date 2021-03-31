
command! -range -nargs=* SeqNumber call SeqNumber(<q-args>)

function! SeqNumber(args)
	let usage = "Usage: SeqNumber [start value] [step]"

	"XXX not working!!!
	"let mode = mode()
	"echo "mode:" . mode
	"if mode != "v" &&  mode != "V" && mode != "CTRL-V"
	"	echo "Not in visual mode"
	"	return 
	"endif
	
	let qargs = split(a:args)

	if len(qargs) != 2
		echo usage
		return
	endif
	
	let startNum = '.'
	if qargs[0] != '.'
		let startNum = eval(qargs[0])
	endif
	let step = eval(qargs[1])

	call s:SeqNumberDo(startNum, step)
endfunc

function! s:SeqNumberDo(startNum,step)
	let [lnum1, col1] = [line("'<"),col("'<")]
	let [lnum2, col2] = [line("'>"),col("'>")]

	"echo "a:startNum:" . a:startNum
	let lines = getline(lnum1, lnum2)
	let newlines = []

	let searchLength = col2
	"blockwise mode, adjust searchLength to the max line length
	if visualmode() == "V"
		for line in lines
			if strlen(line) > searchLength
				let searchLength = strlen(line)
			endif
		endfor
	endif

	"echo "===================="
	"find number position,change it
	let i = 0
	for line in lines

		let startByte = col1 - 1
		"echo "searchLength" . searchLength
		let line_new = strpart(line,0,startByte)
		while 9 
			let matchByte = match(line,"[0-9]\\+",startByte)
			"echo "matchByte:" . matchByte
			if matchByte != -1

				"echo "matchByte:" . matchByte
				let matchstr = matchstr(line,"[0-9]\\+", matchByte)
				let matchstr_len = len(matchstr)
				"echo "startByte:" . startByte
				"echo "matchstr:" . matchstr
				"echo "matchstr_len:" . matchstr_len

				if (matchByte + matchstr_len) > searchLength
					"echo "break"
					let line_new .= strpart(line,startByte)
					break
				endif

				let line_new .= strpart(line,startByte,matchByte-startByte)
				"echo a:startNum
				if type(a:startNum) == type(0)
					"sort the number start by startNum
					"echo a:startNum + i*a:step
					let line_new .= "" . (a:startNum + i*a:step)
				else  " '.'
					"new number = old number + step
					let line_new .= "" . eval(matchstr) + a:step
				endif
				"echo "line_new" . line_new

				let startByte = matchByte + matchstr_len
				let i += 1
			else
				let line_new .= strpart(line,startByte)
				break
			endif
		endwhile
		call add(newlines,line_new)
	endfor

	let startLine = lnum1
	"set new line
	for line in newlines
		call setline(startLine, line)
		let startLine += 1
	endfor
endfunc
