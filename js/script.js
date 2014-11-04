window._i = function(){
  window._i = null;

  var queryUrl = 'http://suggestqueries.google.com/complete/search?client=firefox&callback=_sr&q=';
  var searchUrl = 'http://www.google.com/search?q=';
  var selectedIndex = -1;
  var hotHitSelectedIndex = -1;
  var isHotHitSelectionMode = false;
  var maxResultCount = 7;
  var cachedString = '';
  var globalTimeout = null;

  /** Hot hit list */
  var hotHitDB = [
    {
      name: "Facebook",
      link: "https://www.facebook.com"
    },
    {
      name: "Twitter",
      link: "https://twitter.com"
    },
    {
      name: "Youtube",
      link: "https://www.youtube.com"
    },
    {
      name: "Yahoo",
      link: "https://hk.yahoo.com"
    },
    {
      name: "Pocket",
      link: "https://getpocket.com"
    },
    {
      name: "Feedly",
      link: "http://feedly.com"
    }
  ];

  /** Helper Functions */
  var qs = function(selector){
    return document.querySelector(selector);
  };
  var qsa = function(selector){
    return document.querySelectorAll(selector);
  };
  var newElement = function(elementType){
    return document.createElement(elementType);
  };
  var addClass = function(className, targetElement){
    targetElement.classList.add(className);
  };
  var removeClass = function(className, targetElement){
    targetElement.classList.remove(className);
  };
  var addChild = function(childElement, parentElement){
    parentElement.appendChild(childElement);
  };

  /** Views */
  var searchContainer = qs('#search');
  var resultDisplay = qs('#result');
  var timeDisplay = qs('#time');
  var hotHitDisplay = qs('#hotHit');
  var searchBoxInput = qs('#searchBox');

  /** JSONP Callback */
  window._sr = function(data){
    var resultList = newElement('ul');
    var dataList = data[1];
    selectedIndex = -1;

    if(dataList.length > 0){
      addClass('hide', timeDisplay);
      removeClass('show', hotHitDisplay);
      addClass('active', searchContainer);
    }
    else{
      removeClass('hide', timeDisplay);
      addClass('show', hotHitDisplay);
      removeClass('active', searchContainer);
    }

    dataList.forEach(function(perResult, idx){
      if(idx >= maxResultCount) return;

      var perListItem = newElement('li');
      perListItem.dataset.content = perResult;
      perListItem.textContent = perResult;

      var perListAnchor = newElement('a');
      perListAnchor.href = searchUrl + perResult;
      addChild(perListItem, perListAnchor);

      addChild(perListAnchor, resultList);

      return;
    });

    resultDisplay.innerHTML = resultList.outerHTML;
  };

  var jsonpRequest = function(requestString){
    var newScriptTag = newElement('script');
    newScriptTag.src = queryUrl + requestString;
    addChild(newScriptTag, qs('head'));
  };

  var updateList = function(){
    var targetIndex = isHotHitSelectionMode ?
                      hotHitSelectedIndex : selectedIndex;
    var targetZone = isHotHitSelectionMode ? '#hotHit' : '#result';
    var selectedListItem = qsa(targetZone + ' li.selected');

    for(var idx = 0; idx < selectedListItem.length; idx++){
      var item = selectedListItem[idx];
      removeClass('selected', item);
    }

    if(targetIndex >= 0){
      var targetItem = qs(targetZone +
                          ' a:nth-child(' +
                          (targetIndex + 1) +
                          ') li');
      if(targetItem){
        addClass('selected', targetItem);
        if(!isHotHitSelectionMode)
          searchBoxInput.value = targetItem.dataset.content.trim();
      }
    }
  };

  // TODO: Hack here to track usage
  var changeLocation = function(url){
    if(typeof url == 'string') window.location = url;
  };

  var keyDownHandler = function(event){
    var val = searchBoxInput.value.trim();
    if(val.length === 0 && event.keyCode == 32){ // white space
      isHotHitSelectionMode = true;
      searchBoxInput.blur();
    }
  };

  var keyUpHandler = function(event){
    var val = searchBoxInput.value.trim();
    var allList = [];
    if(val.length > 0){
      allList = qsa('#result li');
      switch(event.keyCode){
        case 38:  // arrow-up
          selectedIndex = selectedIndex < 0 ? -1 : selectedIndex - 1;
          updateList();
          break;

        case 40:  // arrow-down
          selectedIndex += 1;
          if(selectedIndex >= allList.length)
            selectedIndex = selectedIndex % allList.length;
          updateList();
          break;

        case 13:  // enter
          if(selectedIndex >= 0 && selectedIndex < allList.length)
            val = allList[selectedIndex].dataset.content.trim();
          changeLocation(searchUrl + val);
          break;

        default:
          if(val == cachedString) return;

          cachedString = val;
          if(globalTimeout) clearTimeout(globalTimeout);
          globalTimeout = setTimeout(function(){
            jsonpRequest(val);
          }, 500);
      }
    }
    else{
      if(isHotHitSelectionMode){
        allList = qsa('#hotHit li');
        switch(event.keyCode){
          case 38:  // arrow-up
            hotHitSelectedIndex = hotHitSelectedIndex < 0 ?
                                  -1 : hotHitSelectedIndex - 1;
            updateList();
            break;
          case 40:  // arrow-down
            hotHitSelectedIndex += 1;
            if(hotHitSelectedIndex >= allList.length)
              hotHitSelectedIndex = hotHitSelectedIndex % allList.length;
            updateList();
            break;
          case 32:  // white space
            if(hotHitSelectedIndex >= 0 &&
               hotHitSelectedIndex < allList.length){
              var selectedHotHit = allList[hotHitSelectedIndex];
              if(selectedHotHit.dataset.url)
                changeLocation(selectedHotHit.dataset.url);
            }
            else{
              isHotHitSelectionMode = false;
              searchBoxInput.focus();
              hotHitSelectedIndex = -1;
              updateList();
            }
            break;
          case 192:  // backquote
            hotHitSelectedIndex = -1;
            updateList();
            break;
          default:
            if(event.keyCode > 47 && event.keyCode < 58){
              var toSelectIndex = event.keyCode - 49;
              hotHitSelectedIndex = toSelectIndex < allList.length ?
                                    toSelectIndex : -1;
              updateList();
            }
            break;
        }
      }
      else{
        removeClass('hide', timeDisplay);
        removeClass('active', searchContainer);
        addClass('show', hotHitDisplay);
        resultDisplay.innerHTML = '';
        if(globalTimeout) clearTimeout(globalTimeout);
      }
    }
  };

  var updateTime = function(){
    var currentDate = new Date();
    var timeString = currentDate.toTimeString();
    var timeStringMatches = timeString.match(/\d+:\d+:\d+/);
    if(timeStringMatches)
      timeString = timeStringMatches[0];

    timeDisplay.innerHTML = currentDate.toDateString() +
                            ', ' + timeString;
  };

  var updateLayout = function(){
    var innerWidth = window.innerWidth;
    if(innerWidth < 850){
      removeClass('show', hotHitDisplay);
      addClass('nodisplay', hotHitDisplay);
    }
    else{
      addClass('show', hotHitDisplay);
      removeClass('nodisplay', hotHitDisplay);
    }
  };

  var showHotHit = function(){
    hotHitDisplay.innerHTML = hotHitDB.map(function(perHotHit){
      var perHotHitIcon = newElement('img');
      var perHotHitListItem = newElement('li');
      var perHotHitAnchor = newElement('a');

      perHotHitIcon.src = perHotHit.favicon ? perHotHit.favicon :
                          perHotHit.link + '/favicon.ico';

      perHotHitListItem.dataset.name = perHotHit.name;
      perHotHitListItem.dataset.url = perHotHit.link;

      addChild(perHotHitIcon, perHotHitListItem);
      addChild(document.createTextNode(perHotHit.name), perHotHitListItem);

      perHotHitAnchor.href = perHotHit.link;
      addChild(perHotHitListItem, perHotHitAnchor);

      return perHotHitAnchor;

    }).reduce(function(lastItem, currentItem){
      addChild(currentItem, lastItem);
      return lastItem;
    },(newElement('ul'))).outerHTML;
  };

  updateTime();
  setInterval(updateTime, 1000);

  document.addEventListener('keyup', keyUpHandler);
  document.addEventListener('keydown', keyDownHandler);

  showHotHit();
  updateLayout();
  window.addEventListener('resize', updateLayout);

};