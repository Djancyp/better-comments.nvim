# Better Comments - NVIM
Better comments helps you to organize your comments with highlights and virtual text.

# DEMO
![Demo](https://github.com/Djancyp/nvim-plugin-demo/blob/main/better-comment.nvim/images/example.png)
## Installation
### Requirement
in order to use this plugin you need to set up treesiter

[nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Recommended Packer:

```lua
use "Djancyp/better-comments.nvim"
```
### Setup
```lua
require('better-comment').Setup()
```

## Configs
### Default Config
```lua
tags = {
        {
            name = "TODO",
            fg = "white",
            bg = "#0a7aca",
            bold = true,
            virtual_text = "",
        },
        {
            name = "FIX",
            fg = "white",
            bg = "#f44747",
            bold = true,
            virtual_text = "This is virtual Text from FIX",
        },
        {
            name = "WARNING",
            fg = "#FFA500",
            bg = "",
            bold = false,
            virtual_text = "This is virtual Text from WARNING",
        },
        {
            name = "!",
            fg = "#f44747",
            bg = "",
            bold = true,
            virtual_text = "",
        }

    }
```
### Overwrite defaults or add new Config
```lua
require('better-comment').Setup({
tags = {
       // TODO will overwrite
        {
            name = "TODO",
            fg = "white",
            bg = "#0a7aca",
            bold = true,
            virtual_text = "",
        },
       {
            name = "NEW",
            fg = "white",
            bg = "red",
            bold = false,
            virtual_text = "",
        },

    }
})
```


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
