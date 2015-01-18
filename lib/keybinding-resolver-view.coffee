{$$, $, View} = require 'atom'

module.exports =
class KeyBindingResolverView extends View
  @content: ->
    @div class: 'key-binding-resolver tool-panel pannel panel-top padding', =>
      @div class: 'panel-heading padded', =>
        @span 'Key Binding Resolver: '
        @span outlet: 'keystroke', 'Press any key'
      @div outlet: 'commands', class: 'panel-body padded'

  initialize: ({attached})->
    @attach() if attached

    atom.workspaceView.command 'key-binding-resolver:toggle', => @toggle()

    @on 'click', '.source', (event) -> atom.workspaceView.open(event.target.innerText)

  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  attach: ->
    atom.workspaceView.prependToBottom(this)
    @subscribe atom.keymap, "matched", ({keystrokes, binding, keyboardEventTarget}) =>
      @update(keystrokes, binding, keyboardEventTarget)

    @subscribe atom.keymap, "matched-partially", ({keystrokes, partiallyMatchedBindings, keyboardEventTarget}) =>
      @updatePartial(keystrokes, partiallyMatchedBindings)

    @subscribe atom.keymap, "match-failed", ({keystrokes, keyboardEventTarget}) =>
      @update(keystrokes, null, keyboardEventTarget)

  detach: ->
    super
    @unsubscribe()

  update: (keystrokes, keyBinding, keyboardEventTarget) ->
    @keystroke.html $$ ->
      @span class: 'keystroke', keystrokes

    unusedKeyBindings = atom.keymap.findKeyBindings({keystrokes, target: keyboardEventTarget}).filter (binding) ->
      binding != keyBinding

    unmatchedKeyBindings = atom.keymap.findKeyBindings({keystrokes}).filter (binding) ->
      binding != keyBinding and binding not in unusedKeyBindings

    @commands.html $$ ->
      @div class: 'table-condensed', =>
        if keyBinding
          @div class: 'used', =>
            @div class: 'command', keyBinding.command
            @div class: 'selector', keyBinding.selector
            @div class: 'source', keyBinding.source

        for binding in unusedKeyBindings
          @div class: 'unused', =>
            @div class: 'command', binding.command
            @div class: 'selector', binding.selector
            @div class: 'source', binding.source

        for binding in unmatchedKeyBindings
          @div class: 'unmatched', =>
            @div class: 'command', binding.command
            @div class: 'selector', binding.selector
            @div class: 'source', binding.source

  updatePartial: (keystrokes, keyBindings) ->
    @keystroke.html $$ ->
      @div class: 'keystroke', "#{keystrokes} (partial)"

    @commands.html $$ ->
      @div class: 'table-condensed', =>
        for binding in keyBindings
          @div class: 'unused', =>
            @div class: 'command', binding.command
            @div class: 'keystrokes', binding.keystrokes
            @div class: 'selector', binding.selector
            @div class: 'source', binding.source
