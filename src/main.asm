
.386
.model            flat,stdcall
option            casemap    :none

include            windows.inc
include            user32.inc
includelib         user32.lib
include            kernel32.inc
includelib         kernel32.lib

DLG_ID    equ    1
ADD_BUTTON_ID equ 1001
RESET_BUTTON_ID equ 1002
SCORE_LIST_BOX_ID equ 1000
TEXT_EDITOR_ID equ 1003

.data
massageBoxTitle db 'Hi~ I', 27h,'m Raiix!', 0
info1           db 'The random score is: ', 0
levalMap        db ':ABCD '
;用于信息框的文本
info2           db 'Info:', 0dh, 0ah, 0
info3           db 'A: ', 0
info4           db 'B: ', 0
info5           db 'C: ', 0
info6           db 'D: ', 0
brStr           db 0dh, 0ah, 0;换行符
percentStr      db '%', 0

.data?
hInstance    dd    ?
hListbox     dd    ?
hTextEditor  dd    ?

.code
;获取十进制无符号随机数
GetRandomNumber proc uses ebx ecx edx theStart, theEnd
    invoke GetTickCount
    mov ebx, theStart
    mov ecx, theEnd
    sub ecx, ebx;size

    mov edx, 0
    div ecx;edx = eax % ecx
    
    add ebx, edx
    mov eax, ebx;eax = theStart + edx
    ret
GetRandomNumber endp

;获取字符串长度
StrLen proc uses ebx ecx edx edi esi theStr
    mov ebx, theStr;the address of string
    mov esi, 0;the len
    @@:;loop
        mov al, [ebx][esi]
        cmp al, 0
        jz @F
        inc esi
        jmp @B
    @@:
    mov eax, esi
    ret
StrLen endp

;传入一个整数和一个字符串首地址，需提前申请好足够大的内存空间
;转化成十进制数字字符串
IntToStr proc uses ebx ecx edx edi esi theInt, theStr
    mov eax, theInt

    ;若该整数为0则直接返回字符串“0”
    cmp eax, 0
    jnz @F
    mov ebx, theStr

    mov ecx, 0
    mov dl, 30h
    mov [ebx][ecx], dl

    mov ecx, 1
    mov dl, 0
    mov [ebx][ecx], dl
    ret
    @@:

    mov ecx, 0;the pos in theStr
    @@:
        cmp eax, 0
        jz @F

        ; a = x % 10; x = x / 10;
        mov edx, 0
        mov ebx, 10
        div ebx

        ;add a edx to theStr
        add dl, 30h
        mov ebx, theStr
        mov [ebx][ecx], dl
        inc ecx
        jmp @B
    @@:
    mov ebx, theStr
    mov eax, 0
    mov [ebx][ecx], al

    cmp ecx, 0
    jnz @F
    ret
    @@:

    ;flip str
    mov esi, ecx
    dec esi
    mov ecx, 0

    mov edx, 0
    @@:
        cmp esi, ecx
        jbe @F

        mov ebx, theStr
        mov edx, [ebx][ecx];不能使用[ebx][eax]，否则会出现访问冲突
        push edx
        mov edx, [ebx][esi]

        mov [ebx][ecx], dl
        pop edx
        mov [ebx][esi], dl

        inc ecx
        dec esi
        jmp @B
    @@:
    ret
IntToStr endp

;连接两个字符串A,B到字符串Res中
ConcatStr proc uses ebx ecx edi esi, strA, strB, strRes
    local lenA:dword, lenB:dword, ai, bi, ri
    invoke StrLen, strA
    mov lenA, eax
    invoke StrLen, strB
    mov lenB, eax

    mov ai, 0
    mov bi, 0
    mov ri, 0

    mov edx, lenA
    @@:
        mov ecx, ai
        cmp ecx, edx
        jz @F

        mov ebx, strA
        mov ecx, ai
        mov eax, [ebx][ecx]

        mov ebx, strRes
        mov ecx, ri
        mov [ebx][ecx], al

        mov ecx, ai
        inc ecx
        mov ai, ecx

        mov ecx, ri
        inc ecx
        mov ri, ecx

        jmp @B
    @@:

    mov edx, lenB
    @@:
        mov ecx, bi
        cmp ecx, edx
        jz @F

        mov ebx, strB
        mov ecx, bi
        mov eax, [ebx][ecx]

        mov ebx, strRes
        mov ecx, ri
        mov [ebx][ecx], al

        mov ecx, bi
        inc ecx
        mov bi, ecx

        mov ecx, ri
        inc ecx
        mov ri, ecx
        
        jmp @B
    @@:

    mov ebx, strRes
    mov ecx, ri
    mov eax, 0
    mov [ebx][ecx], eax

    mov eax, ri
    ret
ConcatStr endp

;根据分数返回等级
GetLevelByScore proc uses ebx ecx edi esi, score
    mov ebx, score

    mov ecx, 90
    cmp ebx, ecx
    mov eax, 1
    jge @F

    mov ecx, 80
    cmp ebx, ecx
    mov eax, 2
    jge @F

    mov ecx, 70
    cmp ebx, ecx
    mov eax, 3
    jge @F

    mov ecx, 60
    cmp ebx, ecx
    mov eax, 4
    jge @F

    mov eax, 5
@@:
    ret
GetLevelByScore endp

;计算给定等级所占总分数的百分比（整数）
CalcScoreByLevel proc uses ebx ecx edi esi, hWnd, level
    local sum, levelSum, num, i
    ;初始化
    mov sum, 0
    mov levelSum, 0
    mov num, 0
    mov i, 0

    ;获取数据总数
    invoke SendDlgItemMessage, hWnd, SCORE_LIST_BOX_ID, LB_GETCOUNT, 0, 0
    mov num, eax

    ;遍历每项数据
    mov i, 0
    @@:
    mov ebx, i
    mov ecx, num
    cmp ebx, ecx
    jz @F
        invoke SendDlgItemMessage, hWnd, SCORE_LIST_BOX_ID, LB_GETITEMDATA, i, 0

        ;统计总分数
        mov ebx, sum
        add ebx, eax
        mov sum, ebx

        mov ecx, eax

        ;统计等级总分数
        invoke GetLevelByScore, eax
        mov ebx, level
        cmp eax, ebx
        jnz if_no
        mov ebx, levelSum
        add ebx, ecx
        mov levelSum, ebx
        if_no:

    mov ebx, i
    inc ebx
    mov i, ebx
    jmp @B
    @@:

    ;计算百分比
    mov edx, 0
    mov eax, levelSum
    mov ecx, 100
    mul ecx; levelSum *= 100
    mov ebx, sum
    div ebx; result = levelSum / sum

    ret
CalcScoreByLevel endp

;添加按钮点击事件
OnAddButtonClicked proc uses ebx ecx edi esi, hWnd
    local strA[10]:byte, strRes[2048], levelStr[3]:byte, randomNumber, hasLevel

    ;获取随机数
    invoke    GetRandomNumber, 0, 100
    mov ecx, eax
    mov randomNumber, eax

    ;判断等级
    mov bl, levalMap[0]
    mov levelStr[0], bl

    invoke GetLevelByScore, ecx
    mov bl, levalMap[eax]
    mov levelStr[1], bl

    mov levelStr[2], 0

    ;判断是否拥有等级
    mov hasLevel, 0
    cmp eax, 5
    jz @F
    mov hasLevel, 1
    @@:

    ;将随机数转换成字符串
    invoke    IntToStr, ecx, addr strA

    ;连接提示信息
    invoke    ConcatStr, addr info1, addr strA, addr strRes
    invoke    MessageBox, hWnd, addr strRes, offset massageBoxTitle, MB_OK

    ;添加到列表框
    mov edx, hasLevel
    cmp edx, 1
    jnz if_no
    if_yes:
        invoke    ConcatStr, addr strA, addr levelStr, addr strRes
        invoke    SendDlgItemMessage, hWnd, SCORE_LIST_BOX_ID, LB_ADDSTRING, 0, addr strRes
        jmp end_if
    if_no:
        invoke    SendDlgItemMessage, hWnd, SCORE_LIST_BOX_ID, LB_ADDSTRING, 0, addr strA
    end_if:
    ;将分数作为附加数据添加到列表框里
    invoke    SendDlgItemMessage, hWnd, SCORE_LIST_BOX_ID, LB_SETITEMDATA, eax, randomNumber

    ;更新文本框信息
    invoke    ConcatStr, addr info2, addr info3, addr strRes
    invoke    CalcScoreByLevel, hWnd, 1;计算A
    mov       ebx, eax
    invoke    IntToStr, ebx, addr strA
    invoke    ConcatStr, addr strRes, addr strA, addr strRes
    invoke    ConcatStr, addr strRes, addr percentStr, addr strRes

    invoke    ConcatStr, addr strRes, addr brStr, addr strRes
    invoke    ConcatStr, addr strRes, addr info4, addr strRes
    invoke    CalcScoreByLevel, hWnd, 2;计算B
    mov       ebx, eax
    invoke    IntToStr, ebx, addr strA
    invoke    ConcatStr, addr strRes, addr strA, addr strRes
    invoke    ConcatStr, addr strRes, addr percentStr, addr strRes

    invoke    ConcatStr, addr strRes, addr brStr, addr strRes
    invoke    ConcatStr, addr strRes, addr info5, addr strRes
    invoke    CalcScoreByLevel, hWnd, 3;计算C
    mov       ebx, eax
    invoke    IntToStr, ebx, addr strA
    invoke    ConcatStr, addr strRes, addr strA, addr strRes
    invoke    ConcatStr, addr strRes, addr percentStr, addr strRes

    invoke    ConcatStr, addr strRes, addr brStr, addr strRes
    invoke    ConcatStr, addr strRes, addr info6, addr strRes
    invoke    CalcScoreByLevel, hWnd, 4;计算D
    mov       ebx, eax
    invoke    IntToStr, ebx, addr strA
    invoke    ConcatStr, addr strRes, addr strA, addr strRes
    invoke    ConcatStr, addr strRes, addr percentStr, addr strRes

    invoke    SetWindowText, hTextEditor, addr strRes

    ret
OnAddButtonClicked endp

;消息处理
ProcDlg proc uses ebx ecx edi esi hWnd, wMsg, wParam, lParam
    local strRes[2048]:byte
    mov    eax, wMsg
    .if eax == WM_CLOSE
        invoke    EndDialog, hWnd, NULL
    .elseif eax == WM_INITDIALOG
        ;invoke    LoadIcon,hInstance,ICO_MAIN
        ;invoke    SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
        ;获取文本编辑器的句柄
        invoke    GetDlgItem, hWnd, TEXT_EDITOR_ID
        mov hTextEditor, eax
    .elseif eax == WM_COMMAND
        mov    eax, wParam
        .if ax == IDOK
                invoke    EndDialog, hWnd, NULL
        .endif
        ;get button id in ebx
        ;invoke    LOWORD, wParam
        mov    ebx, wParam
        and    ebx, 0000ffffh
        ;get event type in eax
        ;invoke    HIWORD, wParam
        .if ebx == ADD_BUTTON_ID ; on add button clicked
                invoke OnAddButtonClicked, hWnd
        .endif
        .if ebx == RESET_BUTTON_ID ; on reset button clicked
                ; invoke MessageBox, hWnd, offset massageBoxTitle, offset massageBoxTitle, MB_OK
                mov strRes[0], 0
                invoke SetWindowText, hTextEditor, addr strRes
                invoke SendDlgItemMessage, hWnd, SCORE_LIST_BOX_ID, LB_RESETCONTENT, 0, 0
        .endif
    .else
        mov    eax, FALSE
        ret
    .endif
    mov    eax, TRUE
    ret
ProcDlg    endp

;主过程
start:
    invoke    GetModuleHandle, NULL
    mov       hInstance, eax
    invoke    DialogBoxParam, hInstance, DLG_ID, NULL, offset ProcDlg, NULL
    invoke    ExitProcess, NULL
    end       start