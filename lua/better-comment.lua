local msg = 
  debug.traceback("`better-comment` module is deprecated. Please use `better-comments` instead.", 2)
vim.notify(msg, vim.log.levels.WARN, { title = "better-comments", once = true })
return require("better-comments")
