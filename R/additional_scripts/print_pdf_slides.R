# Print the html slides as pdf

slide_path <- here::here("slides.html")

pagedown::chrome_print(slide_path, output = here::here("slides.pdf"))
