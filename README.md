# temper

Common Listp templating language.

## Usage

```html
<% (loop :for i in '(1 2 3)) %>
    <li> <%= i %> </li>
<% ) %>
```

## TODO

* [x] value interpolation (e.g `<%= link %>`)
* [x] inject variable in local scope
