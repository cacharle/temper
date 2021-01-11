# temper

Common Listp templating engine inspired by [ejs](https://ejs.co/).

## Usage

### From the command line

```command
$ ./temper.lisp template.lisp.html > generated.html
```

```command
$ ./temper.lisp template_directory
```

### In the template

You can put any Common lisp code between `<%` and `%>`.  
Put the result of a form in the template with `<%=`.

```html
<ul>
  <% (dotimes (n 10)) %>
    <li> <%= n %> </li>
  <% ) %>
</ul>
```

Use the `render` function to include a template in another.

```html
<% (render "header.lisp.html") %>
<p>that's pretty neat</p>
<% (render "footer.lisp.html") %>
```

## TODO

* [x] value interpolation (e.g `<%= link %>`)
* [x] inject variable in local scope
* [x] auto index function from directory name
    * [ ] add date support
    * [ ] sort by date
    * [ ] hook for setting link name
* [ ] relative path from the file and the current directory
* [ ] walk down a directory and generate all templates
* [ ] link generator `<%= (link 'about') %>` returns `about.html`
      and check if `about.lisp.html` exists
* [ ] Makefile to compile and install
* [ ] escape interpolated value
* [ ] file/directory command line arguments
* [ ] passing template variable in command line
* [ ] extends a base template (like Django)
