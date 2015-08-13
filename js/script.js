window._i = function(){
  var queryUrl = 'http://suggestqueries.google.com/complete/search?client=firefox&callback=_sr&q=',
      searchUrl = 'http://www.google.com/search?q=',
      selectedIndex = -1,
      isFavListSelectionMode = false,
      maxResultCount = 7,
      maxResultCountMobile = 2,
      mobileHeightBreakPoint = 560,
      cachedString = '',
      globalTimeout = null,
      _window = window;

  /** Helper Functions */
  var qs = function(selector, rootNode){
        if (rootNode !== undefined)
          return rootNode.querySelector(selector);
        else return document.querySelector(selector);
      },

      qsa = function(selector, rootNode){
        if (rootNode !== undefined)
          return rootNode.querySelectorAll(selector);
        else return document.querySelectorAll(selector);
      },

      newElement = function(elementType){
        return document.createElement(elementType);
      },

      addClass = function(className, targetElement){
        targetElement.classList.add(className);
      },

      removeClass = function(className, targetElement){
        targetElement.classList.remove(className);
      },

      addChild = function(childElement, parentElement){
        parentElement.appendChild(childElement);
      },

      jsonpRequest = function(requestString){
        var newScriptTag = newElement('script');
        newScriptTag.src = queryUrl + encodeURIComponent(requestString);
        addChild(newScriptTag, qs('head'));
      },

      changeLocation = function(url){
        if(typeof url == 'string') _window.location = url;
      };


      /** Views */
  var mainContainer = qs('main'),
      favListDisplay = qs('.fav_list'),
      resultDisplay = qs('.search_result', mainContainer),
      timeDisplay = qs('.time_display', mainContainer),
      searchBoxInput = qs('input[type="text"]', mainContainer);


  var updateList = function(){
        var targetZone = isFavListSelectionMode ? favListDisplay : resultDisplay,
            selectedListItem = qsa('li.selected', targetZone);

        for(var idx = 0; idx < selectedListItem.length; idx++){
          var item = selectedListItem[idx];
          removeClass('selected', item);
        }

        if(selectedIndex >= 0){
          var targetItem = qs('a:nth-child(' + (selectedIndex + 1) + ') li',
                              targetZone);
          if(targetItem){
            addClass('selected', targetItem);
            if(!isFavListSelectionMode)
              searchBoxInput.value = targetItem.dataset.content.trim();
          }
        }
      },

      updateTime = function(){
        var currentDate = new Date(),
            timeString = currentDate.toTimeString(),
            timeStringMatches = timeString.match(/\d+:\d+:\d+/);

        if(timeStringMatches)
          timeString = timeStringMatches[0];

        timeDisplay.innerHTML = currentDate.toDateString() +
                                ', ' + timeString;
      },

      showFavList = function(){
        // use map-reduce function to construct the fav list
        favListDisplay.innerHTML = _window.getFavList()
          .map(
            function(perFav){
              var perFavIcon = newElement('img'),
                  perFavListItem = newElement('li'),
                  perFavAnchor = newElement('a');

              perFavIcon.src = perFav.favicon ? perFav.favicon :
                                  perFav.link + '/favicon.ico';

              perFavListItem.dataset.name = perFav.name;
              perFavListItem.dataset.url = perFav.link;

              addChild(perFavIcon, perFavListItem);
              addChild(document.createTextNode(perFav.name), perFavListItem);

              perFavAnchor.href = perFav.link;
              addChild(perFavListItem, perFavAnchor);

              return perFavAnchor;
            }
          )
          .reduce(
            function(lastItem, currentItem){
              addChild(currentItem, lastItem);
              return lastItem;
            }, (newElement('ul'))
          )
          .outerHTML;

          addClass('show', favListDisplay);
      };


  /* key handlers */
  var keyDownHandler = function(event){
        var val = searchBoxInput.value.trim();
        if(val.length === 0 && event.keyCode == 32){ // white space
          var left = parseInt(_window.getComputedStyle(favListDisplay).left);

          if (left >= 0) {
            isFavListSelectionMode = true;
            searchBoxInput.blur();
          }
        }
      },

      keyUpHandler = function(event){
        var val = searchBoxInput.value.trim();
        var allList = [];
        var keyCode = event.keyCode;
        if(val.length > 0 || isFavListSelectionMode){
          allList = qsa('li',
            (isFavListSelectionMode ? favListDisplay : resultDisplay));

          switch(keyCode){
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

            case 32:  // white space
              if(isFavListSelectionMode){    // for hot-hit mode only
                if(selectedIndex >= 0 &&
                   selectedIndex < allList.length){
                  var selectedFav = allList[selectedIndex];
                  if(selectedFav.dataset.url)
                    changeLocation(selectedFav.dataset.url);
                }
                else{
                  isFavListSelectionMode = false;
                  searchBoxInput.focus();
                  selectedIndex = -1;
                  updateList();
                }
              }
              break;

            case 192:  // backquote
              if(isFavListSelectionMode){    // for hot-hit mode only
                selectedIndex = -1;
                updateList();
              }
              break;

            case 13:  // enter
              if(!isFavListSelectionMode){   // for search mode only
                if(selectedIndex >= 0 && selectedIndex < allList.length)
                  val = allList[selectedIndex].dataset.content.trim();
                changeLocation(searchUrl + encodeURIComponent(val));
              }
              break;

            default:
              if(!isFavListSelectionMode){    // for search mode
                if(val == cachedString) return;

                cachedString = val;
                if(globalTimeout) clearTimeout(globalTimeout);
                globalTimeout = setTimeout(function(){
                  jsonpRequest(val);
                }, 500);
              }
              else{                         // for hot-hit mode
                if(keyCode > 47 && keyCode < 58){   // only handle 0 ~ 9 num key
                    var toSelectIndex = keyCode - 49;
                    selectedIndex = toSelectIndex < allList.length ?
                                          toSelectIndex : -1;
                    updateList();
                  }
                  break;
              }

          }  // end of switch statement
        }
        else{   // reset to default view
          removeClass('hide', timeDisplay);
          removeClass('active', mainContainer);
          addClass('show', favListDisplay);
          resultDisplay.innerHTML = '';
          if(globalTimeout) clearTimeout(globalTimeout);
        }
      };


  /** JSONP Callback */
  _window._sr = function(data){
    var resultList = newElement('ul'),
        dataList = data[1],
        resultCountLimit = _window.innerHeight > mobileHeightBreakPoint ?
                   maxResultCount : maxResultCountMobile;

    selectedIndex = -1;

    if(dataList.length > 0){
      addClass('hide', timeDisplay);
      removeClass('show', favListDisplay);
      addClass('active', mainContainer);
    }
    else{
      removeClass('hide', timeDisplay);
      addClass('show', favListDisplay);
      removeClass('active', mainContainer);
    }

    dataList.forEach(function(perResult, idx){
      if(idx >= resultCountLimit) return;

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


  updateTime();
  setInterval(updateTime, 1000);

  document.addEventListener('keyup', keyUpHandler);
  document.addEventListener('keydown', keyDownHandler);

  showFavList();

  _window._i = null;
};
