
window._i = () ->
    window._i = null
    globalTimeout = null
    queryUrl = 'http://suggestqueries.google.com/complete/search?client=firefox&callback=_sr&q='
    searchUrl = 'http://www.google.com/search?q='
    selectedIndex = -1
    maxResultCount = 5
    cachedString = ''

    # function definition
    qs = (selector) -> document.querySelector selector

    qsa = (selector) -> document.querySelectorAll selector

    searchContainer = qs('#search')
    resultDisplay = qs('#result')
    window._sr = (data) ->
        selectedIndex = -1
        resultString = '<ul>'

        dataList = data[1]

        if dataList.length > 0
            timeDisplay.classList.add 'hide'
            searchContainer.classList.add 'active'
        else
            timeDisplay.classList.remove 'hide'
            searchContainer.classList.remove 'active'

        dataList.forEach (perResult, idx) ->
            return if idx >= maxResultCount
            resultString += "<a href=\"#{searchUrl+perResult}\">"
            resultString += "<li data-content=\"#{perResult}\">"
            resultString += " #{perResult} </li></a>"
            return

        resultString += '</ul>'
        resultDisplay.innerHTML = resultString

        return

    jsonpRequest = (requestString) ->
        newStringTag = document.createElement 'script'
        newStringTag.src = queryUrl + requestString
        qs('head').appendChild newStringTag
        return

    updateList = () ->
        for item in qsa '#result li.selected'
            item.classList.remove 'selected'

        allListItems = qsa('#result li')

        if selectedIndex >= 0 and selectedIndex < allListItems.length
            selectedItem = allListItems[selectedIndex]
            selectedItem.classList.add 'selected'
            qs('#searchBox').value = selectedItem.dataset.content.trim()

        return

    qs('body').addEventListener 'keyup', (event) ->
        val = qs('#searchBox').value.trim()

        if val.length > 0
            allList = qsa '#result li'
            switch event.keyCode
                when 38     # arrow-up
                    selectedIndex -= 1
                    selectedIndex = if selectedIndex < -1 then -1 else selectedIndex
                    updateList()
                when 40     # arrow-down
                    selectedIndex += 1
                    selectedIndex = if selectedIndex >= allList.length then selectedIndex % allList.length else selectedIndex
                    updateList()
                when 13     # enter
                    if selectedIndex >= 0 and selectedIndex < allList.length
                        val = allList[selectedIndex].dataset.content.trim()
                    window.location = searchUrl + encodeURI val
                else
                    return if val is cachedString

                    cachedString = val
                    clearTimeout(globalTimeout) if globalTimeout
                    globalTimeout = setTimeout () ->
                        jsonpRequest val
                    , 500
        else
            timeDisplay.classList.remove 'hide'
            searchContainer.classList.remove 'active'
            resultDisplay.innerHTML = ''
            clearTimeout(globalTimeout) if globalTimeout
        return

    timeDisplay = qs '#time'
    if timeDisplay
        updateTime = () ->
            currentDate = new Date()

            timeString = currentDate.toTimeString()
            timeStringMatches = timeString.match /\d+:\d+:\d+/
            timeString = timeStringMatches[0] if timeStringMatches

            timeDisplay.innerHTML = currentDate.toDateString() + ', ' + timeString

            return;

        updateTime()
        setInterval updateTime, 1000

    return
