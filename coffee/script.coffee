
window._i = () ->
    window._i = null
    globalTimeout = null
    queryUrl = 'http://suggestqueries.google.com/complete/search?\
    client=firefox&callback=_sr&q='
    searchUrl = 'http://www.google.com/search?q='
    selectedIndex = -1
    hotHitSelectedIndex = -1
    isHotHitSelectionMode = no
    maxResultCount = 7
    cachedString = ''
    hotHitDB = [
            name: "Facebook"
            link: "https://www.facebook.com"
        ,
            name: "Twitter"
            link: "https://twitter.com"
        ,
            name: "Youtube"
            link: "https://www.youtube.com"
        ,
            name: "Yahoo"
            link: "https://hk.yahoo.com"
        ,
            name: "Pocket"
            link: "https://getpocket.com"
        ,
            name: "Feedly"
            link: "http://feedly.com"
    ]

    #helper functions
    qs = (selector) -> document.querySelector selector
    qsa = (selector) -> document.querySelectorAll selector

    #views
    searchContainer = qs '#search'
    resultDisplay = qs '#result'
    timeDisplay = qs '#time'
    hotHitDisplay = qs '#hotHit'
    searchBoxInput = qs '#searchBox'

    window._sr = (data) ->
        selectedIndex = -1
        resultList = document.createElement 'ul'

        dataList = data[1]

        if dataList.length > 0
            timeDisplay.classList.add 'hide'
            hotHitDisplay.classList.remove 'show'
            searchContainer.classList.add 'active'
        else
            timeDisplay.classList.remove 'hide'
            hotHitDisplay.classList.add 'show'
            searchContainer.classList.remove 'active'

        dataList.forEach (perResult, idx) ->
            return if idx >= maxResultCount

            perListItem = document.createElement 'li'
            perListItem.dataset.content = perResult
            perListItem.textContent = perResult

            perListAnchor = document.createElement 'a'
            perListAnchor.href = searchUrl + perResult
            perListAnchor.appendChild perListItem

            resultList.appendChild perListAnchor

            return

        resultDisplay.innerHTML = resultList.outerHTML

        return

    jsonpRequest = (requestString) ->
        newStringTag = document.createElement 'script'
        newStringTag.src = queryUrl + requestString
        qs('head').appendChild newStringTag
        return

    updateList = () ->
        targetZone = if isHotHitSelectionMode then '#hotHit'
        else '#result'
        for item in qsa "#{targetZone} li.selected"
            item.classList.remove 'selected'

        targetIndex =
            if isHotHitSelectionMode then hotHitSelectedIndex
            else selectedIndex

        if targetIndex >= 0
            targetItem = qs("#{targetZone} a:nth-child(#{targetIndex+1}) li")
            if targetItem?
                targetItem.classList.add 'selected'
                if not isHotHitSelectionMode
                    searchBoxInput.value =
                        targetItem.dataset.content.trim()
        return

    changeLocation = (url) ->
        if typeof url is 'string'
            window.location = url

    keyDownHandler = (event) ->
        val = searchBoxInput.value.trim()
        if val.length is 0 and event.keyCode is 32   # white space
            isHotHitSelectionMode = yes
            searchBoxInput.blur()
        return

    keyUpHandler = (event) ->
        val = searchBoxInput.value.trim()
        if val.length > 0
            allList = qsa('#result li')
            switch event.keyCode
                when 38     # arrow-up
                    selectedIndex -= 1
                    selectedIndex = -1 if selectedIndex < -1
                    updateList()
                when 40     # arrow-down
                    selectedIndex += 1
                    if selectedIndex >= allList.length
                        selectedIndex = selectedIndex % allList.length
                    updateList()
                when 13     # enter
                    if selectedIndex >= 0 and
                    selectedIndex < allList.length
                        val = allList[selectedIndex].dataset.content.trim()
                    changeLocation (searchUrl + encodeURI val)
                else
                    return if val is cachedString

                    cachedString = val
                    clearTimeout(globalTimeout) if globalTimeout
                    globalTimeout = setTimeout () ->
                        jsonpRequest val
                    , 500
        else
            if isHotHitSelectionMode
                allList = qsa('#hotHit li')
                switch event.keyCode
                    when 38     # arrow-up
                        hotHitSelectedIndex -= 1
                        hotHitSelectedIndex = -1 if hotHitSelectedIndex < -1
                        updateList()
                        return
                    when 40     # arrow-down
                        hotHitSelectedIndex += 1
                        if hotHitSelectedIndex >= allList.length
                            hotHitSelectedIndex =
                                hotHitSelectedIndex % allList.length
                        updateList()
                        return
                    when 32    # white space
                        isHotHitSelectionMode = no
                        searchBoxInput.focus()

                        if hotHitSelectedIndex >=0 and \
                        hotHitSelectedIndex < allList.length
                            selectedHotHit = allList[hotHitSelectedIndex]
                            changeLocation selectedHotHit.dataset.url \
                            if selectedHotHit.dataset.url

                        hotHitSelectedIndex = -1
                        return
                    when 48,49,50,51,52,53,54,55,56,57    # Key 1 ~ 9
                        toSelectIndex = event.keyCode - 49
                        hotHitSelectedIndex =
                            if toSelectIndex < allList.length \
                            then toSelectIndex else -1
                        updateList()
                        return
                    when 192                            # Key backquote
                        hotHitSelectedIndex = -1
                        updateList()
                        return
            else
                timeDisplay.classList.remove 'hide'
                hotHitDisplay.classList.add 'show'
                searchContainer.classList.remove 'active'
                resultDisplay.innerHTML = ''
                clearTimeout(globalTimeout) if globalTimeout
        return

    updateTime = () ->
        currentDate = new Date()

        timeString = currentDate.toTimeString()
        timeStringMatches = timeString.match /\d+:\d+:\d+/
        timeString = timeStringMatches[0] if timeStringMatches

        timeDisplay.innerHTML = currentDate.toDateString() + ', ' + timeString

        return;

    updateLayout = () ->
        innerWidth = window.innerWidth
        if innerWidth < 850
            hotHitDisplay.classList.remove 'show'
            hotHitDisplay.classList.add 'nodisplay'
        else
            hotHitDisplay.classList.add 'show'
            hotHitDisplay.classList.remove 'nodisplay'

    showHotHit = () ->
        hotHitDisplay.innerHTML = hotHitDB.map (perHotHit) ->
            perHotHitIcon = document.createElement 'img'
            if perHotHit.favicon
                perHotHitIcon.src = perHotHit.favicon
            else
                perHotHitIcon.src = perHotHit.link + '/favicon.ico'

            perHotHitListItem = document.createElement 'li'
            perHotHitListItem.dataset.name = perHotHit.name
            perHotHitListItem.dataset.url = perHotHit.link
            perHotHitListItem.appendChild perHotHitIcon
            perHotHitListItem.appendChild \
            (document.createTextNode(perHotHit.name))

            perHotHitAnchor = document.createElement 'a'
            perHotHitAnchor.href = perHotHit.link
            perHotHitAnchor.appendChild perHotHitListItem

            return perHotHitAnchor

        .reduce (lastItem, currentItem) ->
            lastItem.appendChild currentItem
            return lastItem
        , (document.createElement 'ul')

        .outerHTML

        return


    updateTime()
    setInterval updateTime, 1000

    document.addEventListener 'keyup', keyUpHandler
    document.addEventListener 'keydown', keyDownHandler

    showHotHit()
    updateLayout()
    window.addEventListener 'resize', updateLayout

    return
