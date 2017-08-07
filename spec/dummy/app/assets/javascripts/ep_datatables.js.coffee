onDataTableInitComplete = (settings) ->
  for column in settings.aoColumns when column.bSearchable
    $(column.nTh).append(" " + fa_icon("filter"))

default_opts =
  jQueryUI: true
  autoWidth: true
  pagingType: "full_numbers"
  processing: true
  serverSide: true
  responsive: true
  initComplete: onDataTableInitComplete
  language:
    search: "Suche:"
    processing: "Verarbeite Daten..."
    zeroRecords: "Keine Daten vorhanden"
    loadingRecords: "Hole Daten..."
    lengthMenu: "Zeige _MENU_ Einträge"
    info: "Zeige Datensätze _START_ bis _END_ von _TOTAL_"
    infoEmpty: "Keine Daten gefunden"
    infoFiltered: "(von _MAX_ Datensätzen)"
    emptyTable: "Keine Daten gefunden"
    decimal: ","
    paginate:
      first: "Erste"
      previous: "Vorherige"
      next: "Nächste"
      last: "Letzte"
    aria:
      sortAscending: ": aktivieren, um Spalte aufsteigend zu sortieren"
      sortDescending: ": aktivieren, um Spalte absteigend zu sortieren"

mergeDefaultOpts = (options) ->
  options[prop] = value for own prop, value of default_opts unless options.prop?
  options

# register a datatable instance which will be initialized once the document
# has been loaded, using the `data-source` attribute as an AJAX source
window.registerDataTable = (selector, options) ->
  $ () ->
    options.ajax = $(selector).attr("data-source")
    $(selector).dataTable(mergeDefaultOpts(options))

# a cell renderer that shows a Font Awesome checkbox-icon for boolean values
checkbox_renderer = (data, type, _full, _meta) ->
  if type == "display"
    if data
      fa_icon("check-square-o")
    else
      fa_icon("square-o")
  else
    data

# a cell renderer that uses Moment.js to nicely format a date value
date_renderer = (date_format = "calendar") ->
  (data, type, _full, _meta) ->
    if type == "display"
      if data && data != null
        switch date_format
          when "calendar"
            moment(data).calendar()
          else
            moment(data).format(date_format)
      else
        ""
    else
      data

# wraps a renderer so that it will be renderered with a surrounding link
# if link_data is not undefined, all occurrences of ":id" in the link will
# be substituted with the attribute referenced by link_data from the object
wrap_link_renderer = (renderer, link, link_data) ->
  (data, type, full, meta) ->
    return null unless data
    orig_value = if renderer then renderer(data, type, full, meta) else data
    if (type == "display") && link_data
      "<a href=\"#{link.replace(':id', full[link_data])}\">#{orig_value}</a>"
    else
      orig_value

get_renderer = (type, th) ->
  renderer_name = th.attr("data-column-renderer")
  if renderer_name && window[renderer_name]
    window[renderer_name]
  else
    renderer = switch type
      when "boolean" then checkbox_renderer
      when "date" then date_renderer(th.attr("data-column-date-format"))
      else undefined
    link = th.attr("data-column-link")
    if link
      wrap_link_renderer(renderer, link, th.attr("data-column-link-data"))
    else
      renderer

currency_symbol = (currency) ->
  switch currency
    when "EUR" then "€"
    when "USD" then "$"
    else currency

window.renderCurrency = (data, type, full, meta) ->
  if type == "display"
    "#{parseFloat(data).toFixed(2)}#{currency_symbol(full.currency)}"
  else
    data

# coffeelint: disable=cyclomatic_complexity
$ () ->
# Automagically converts all tables with the declarative-table class into
# DataTables instances
# You can add the following attributes to configure the table:
# - data-source [String] the URL to use to fetch data. Required.
# - data-row-callback [String] the name of a global function to use as row callback
#   See http://datatables.net/reference/option/rowCallback
#
# Columns are read from <th> elements that have a `data-column-data`
# attribute. Additional supported attributes are
# - data-column-searchable [Boolean], defaults to false
# - data-column-orderable [Boolean], defaults to false
# - data-column-type [String]
# - data-column-renderer [String] if this is the name of a global function, it will be set as a callback.
#   See http://datatables.net/reference/option/columns.render
# - data-column-data [String] name of the property in the JSON object used to render the column
# - data-column-function [String] alternative to data-column-data, will use a function to render the column
  $("table.declarative-table").each () ->
    return if $.fn.DataTable.isDataTable(this)

    getGlobalFn = (name) ->
      window[name] if name && _.isFunction(window[name])

    column_defs = $(this).find("th[data-column-data],th[data-column-function]").map (i, th) ->
      th = $(th)
      data = getGlobalFn(th.attr("data-column-function")) || th.attr("data-column-data")
      type = th.attr("data-column-type") || "string"

      data: data
      type: type
      searchable: th.attr("data-column-searchable") || false
      orderable: th.attr("data-column-orderable") || false
      render: get_renderer(type, th)

    wrapped = $(this)
    options = mergeDefaultOpts(
      columns: column_defs
      rowCallback: getGlobalFn(wrapped.attr('data-row-callback'))
      ajax:
        url: wrapped.attr("data-source")
        type: wrapped.attr("data-method") || "GET"
    )
    if wrapped.attr('data-search-placeholder')
      searchPlaceholder = options.language.searchPlaceholder = wrapped.attr('data-search-placeholder')
    if wrapped.attr('data-default-order')
      options.order = [ wrapped.attr('data-default-order').split(',')]
    dt = wrapped.dataTable(options)
    # setting the options.language.searchPlaceholder doesnt work, so we patch it up
    wrapped.parent().find("input[type=search]").attr('placeholder', searchPlaceholder)
