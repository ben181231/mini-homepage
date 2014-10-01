
window._i = () ->
    window._i = null
    globalTimeout = null
    queryUrl = 'http://suggestqueries.google.com/complete/search?client=firefox&callback=_sr&q='
    searchUrl = 'http://www.google.com/search?q='
    selectedIndex = -1
    cachedString = ''

    # function definition
    qs = (selector) -> document.querySelector selector

    qsa = (selector) -> document.querySelectorAll selector

    window._sr = (data) ->
        selectedIndex = -1;
        resultString = '<ul>';

        dataList = data[1]

        if dataList.length > 0
            qs('#search').classList.add 'active'
        else
            qs('#search').classList.remove 'active'

        dataList.forEach (perResult) ->
            resultString += "<li> #{perResult} </li>"
            return

        resultString += '</ul>';
        qs('#result').innerHTML = resultString;

        return

    jsonpRequest = (requestString) ->
        newStringTag = document.createElement 'script'
        newStringTag.src = queryUrl + requestString
        qs('head').appendChild newStringTag
        return

    updateList = () ->
        allSelectedList =
        for item in qsa '#result li.selected'
            item.classList.remove 'selected'

        qsa('#result li')[selectedIndex].classList.add 'selected'

        return

    qs('#searchBox').addEventListener 'keyup', (event) ->
        val = qs('#searchBox').value.trim()

        if val.length > 0
            allList = qsa '#result li'
            switch event.keyCode
                when 38     # arrow-up
                    selectedIndex -= 1
                    selectedIndex = if selectedIndex < -1 then -1 else selectedIndex
                    updateList()
                when 40     # arrow-down
                    selectedIndex += 1;
                    selectedIndex = if selectedIndex >= allList.length then selectedIndex % allList.length else selectedIndex
                    updateList()
                when 13     # enter
                    if selectedIndex >= 0 and selectedIndex < allList.length
                        val = allList[selectedIndex].innerHTML
                    window.location = searchUrl + encodeURI val
                else
                    return if val is cachedString

                    cachedString = val
                    clearTimeout(globalTimeout) if globalTimeout
                    globalTimeout = setTimeout () ->
                        jsonpRequest val
                    , 300
        else
            qs('#search').classList.remove 'active'
            qs('#result').innerHTML = ''
            clearTimeout(globalTimeout) if globalTimeout
        return

    return
