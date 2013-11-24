"=============================================================================
" File: animemap.vim
" Author: mopp
" Created: 2013-11-25
"=============================================================================


scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:api_address = 'http://animemap.net/api/table/'
let s:area_list = [
            \ 'hokkaidou', 'aomori', 'iwate', 'miyagi', 'akita', 'yamagata', 'fukushima',
            \ 'ibaraki', 'tochigi', 'gunma', 'saitama', 'chiba', 'tokyo', 'kanagawa',
            \ 'niigata', 'toyama', 'ishikawa', 'fukui', 'yamanashi', 'nagano', 'gifu',
            \ 'shizuoka', 'aichi', 'mie', 'shiga', 'kyoto', 'osaka', 'hyogo',
            \ 'nara', 'wakayama', 'tottori', 'shimane', 'okayama', 'hiroshima', 'yamaguchi',
            \ 'tokushima', 'kagawa', 'ehime', 'kochi', 'fukuoka', 'saga', 'nagasaki',
            \ 'kumamoto', 'oita', 'miyazaki', 'kagoshima', 'okinawa',
            \ ]

function! unite#sources#animemap#define()
    return s:source
endfunction


" sourceの設定
" actionの振る舞いを独自に実装
let s:source = {
            \ 'name' : 'animemap',
            \ 'description' : 'candidates from anime table',
            \ 'is_volatile' : 0,
            \ 'action_table' : {
            \   'uri' : {
            \       'open' : {
            \           'description' : 'get Selected Problem Description',
            \           'is_selectable' : 0,
            \       },
            \   },
            \ },
            \ 'default_action': {'uri': 'open'},
            \}


" 候補を集めている時、redrawされるとき、入力文字列が変更された時に呼ばれる
" argsとcontextの2つの引数をとる
"   args (List) - Uniteコマンド実行時、sourceに与えられるパラメータのリスト いわゆるコマンドの引数
"   context (Dictionary) - sourceが呼ばれた時のコンテキスト
"   引数がない時は""が渡される。ゆえに、この関数は空文字を扱わなければならない
"   詳しくは unite-notation-{context}
" 戻り値は候補のリスト
"   unite-notation-{candidate}
function! s:source.gather_candidates(args, context)
    let candidates = []

    if len(a:args) == 0
        " 説明用のdummy
        call add(candidates, {
                    \ 'word' : 'Please Select Area',
                    \ 'is_dummy' : 1,
                    \ 'is_matched' : 0,
                    \ })
        call add(candidates, {
                    \ 'word' : '============',
                    \ 'is_dummy' : 1,
                    \ 'is_matched' : 0,
                    \ })

        " kind を source にし
        " もう一度uniteをこのsourceで起動し、menuとして扱う
        " 次のuniteへはvolume番号を渡す
        for i in s:area_list
            call add(candidates, {
                        \ 'word' : i,
                        \ 'kind' : 'source',
                        \ 'action__source_name' : 'animemap',
                        \ 'action__source_args' : [i],
                        \ })
        endfor
    elseif type(a:args[0]) == type('')
        " 説明用のdummy
        call add(candidates, {
                    \ 'word' : 'Please Select Title',
                    \ 'is_dummy' : 1,
                    \ 'is_matched' : 0,
                    \ })

        " 一覧を表示
        let area = a:args[0]
        let parsed_xml = webapi#xml#parseURL('http://animemap.net/api/table/' . area . '.xml')

        for item in parsed_xml.childNodes('response')['child'].childNodes('item')
            " title url time station state next episode cable today week
            let title = item.childNode('title').value()
            let url = item.childNode('url').value()
            let time = item.childNode('time').value()
            let station = item.childNode('station').value()
            let state = item.childNode('state').value()
            let next = item.childNode('next').value()
            let episode = item.childNode('episode').value()
            let cable = item.childNode('cable').value()
            let today = item.childNode('today').value()
            let week = item.childNode('week').value()

            call add(candidates, {
                        \ 'word' : next . ' ' . title,
                        \ 'kind' : 'uri',
                        \ 'action__path' : url,
                        \ })
        endfor
    endif

    return candidates
endfunction


function! s:source.action_table.uri.open.func(candidate)
    call openbrowser#open(a:candidate.action__path)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
