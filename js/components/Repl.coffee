recl = React.createClass
{div,textarea,pre} = React.DOM

module.exports = recl
  render: ->
    preNode = pre({ className: 'alert ' + @state.alertClass }, @state.output)
    emptyNode = pre({ className: 'alert' + @state.alertClass, hidden: true })
    partial = if @state.showOutput then preNode else emptyNode
    div {}, textarea(ref: @setRef), partial
  componentDidMount: ->
    CodeMirror.fromTextArea(ReactDOM.findDOMNode(@ta), @state.options)
  getInitialState: ->
    input: ''
    output: ''
    solution: ''
    showOutput: false
    alertClass: 'alert-info'
    options:
      lineNumbers: true
      extraKeys:
        Enter: @cmSend
      tabSize: 2
      indentWithTabs: false
  setRef: (ref) ->
    @ta = ref
  cleanseUrl: (str) ->
    hex = '0123456789ABCDEF'
    [].map.call(str, (c) ->
      switch true
        when /[a-z0-9._~]/.test(c)
          return c
        when /[ -~]/.test(c)
          n = c.charCodeAt(0)
          return '%' + hex[n / 16 | 0] + hex[n % 16]
        else
          return encodeURIComponent(c)
      return
    ).join ''
  cmSend: (cm) ->
    input = cm.getValue()
    if input == ''
      @hideOutput()
      return
    @send input, @renderOutput
    return
  send: (str, cb) ->
    $.ajax(url: '/.repl-json?eval=' + @cleanseUrl(str)).then cb
    return
  renderOutput: (res) ->
    switch Object.keys(res).join(' ')
      when 'good'
        @setState
          output: res.good
          showOutput: true
          alertClass: 'alert-info'
      when 'bad'
        @setState
          output: res.bad
          showOutput: true
          alertClass: 'alert-danger'
      else
        throw new Error('Unknown result: ' + Object.keys(res))
    return
  hideOutput: ->
    @setState
      showOutput: false
      alertClass: 'alert-info'
    return
