WebSearchListView = require './web-search-list-view'
WebSearchBrowserView = require "./web-search-browser-view"
{CompositeDisposable} = require 'atom'

module.exports = WebSearch =
  WebSearchListView: null
  WebSearchBrowserView: null
  modalPanel: null
  browserPanel: null
  subscriptions: null

  config:
    webservice:
      type: "array"
      default: ["http://google.com/search?q=$q$","http://wikipedia.org/wiki/$q$"]
    browser:
      type: "object"
      properties:
        position:
          default: "right"
          type: "string"
          enum: ["top", "right", "bottom", "left"]
        size:
          type: "integer"
          default: 450
        useragent:
          type: "string"
          description: "default is iOS9 for iPhone."
          default: "Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13A344 Safari/601.1"

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'web-search:search': => @openPanel()

  openPanel: ->
    e = atom.workspace.getActiveTextEditor()
    return unless e?
    @browserHide()
    @WebSearchListView = new WebSearchListView(this)
    @modalPanel ?= atom.workspace.addModalPanel(item: @WebSearchListView)
    @modalPanel.show()
    @WebSearchListView.focusFilterEditor()
    @WebSearchListView.setItems atom.config.get("web-search.webservice")

  search: (webservice)->
    @panelHide()
    e = atom.workspace.getActiveTextEditor()
    return unless e?
    text = if e.getSelectedText().length > 0 then e.getSelectedText() else "atom-web-search"
    position = atom.config.get("web-search.browser.position")
    params = {
      url: webservice.replace("$q$", text),
      size: atom.config.get("web-search.browser.size"),
      useragent: atom.config.get("web-search.browser.useragent"),
      position: position
    }
    @webSearchBrowserView = new WebSearchBrowserView(params, this)
    @browserPanel = switch position
      when "top"    then atom.workspace.addTopPanel(item: @webSearchBrowserView)
      when "right"  then atom.workspace.addRightPanel(item: @webSearchBrowserView)
      when "bottom" then atom.workspace.addBottomPanel(item: @webSearchBrowserView)
      when "left"   then atom.workspace.addLeftPanel(item: @webSearchBrowserView)

  deactivate: ->
    @modalPanel.destroy()
    @browserPanel.destroy()
    @subscriptions.dispose()
    @WebSearchListView.destroy()
    @webSearchBrowserView.destroy()

  panelHide: ->
    @modalPanel?.hide()
    @modalPanel = null

  browserHide: ->
    @browserPanel?.hide()
    @browserPanel = null
