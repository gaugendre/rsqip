RSQIP - SVG-Based Image Placeholder... in ruby
====================
## Overview

Ruby port of npm's [sqip](https://github.com/technopagan/sqip) wrapping primitive and svgo


## Requirements
* Primitive (https://github.com/fogleman/primitive)
* SVGO https://github.com/svg/svgo

## Installation

**TODO**

```bash
npm install -g svgo
go get -u github.com/fogleman/primitive
gem install rsqip

```

## Examples

**TODO**

```ruby
rsqip = Rsqip.new(filename).run
width, height = rsqip.img_dimensions
style = "background-size: cover; background-image: url(data:image/svg+xml;base64,${rsqip.svg_base64encoded});"
html = %(<img width="#{width}" height="#{height}" src="#{filename}" style="#{style}" alt="Add descriptive alt text">)
```

## CLI Examples

just use npm

## Licence

This is free and unencumbered software released into the public domain.
