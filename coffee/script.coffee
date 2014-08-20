window.onload = () ->
    console.log 'Window onload - ' + (new Date()).getTime()
    return

window._i = () ->
    console.log 'Document onload - ' + (new Date()).getTime()
    window._i = null
    return;