---
author: "Wes Hinsley"
date: 2019-10-05
title: gotchaR - Bumps in the road for the learneR driver.
best: false
---

I am about 3 years into the journey of learning R. There is a lot to get used to,
when my previous landmarks have been languages based around Java, C, Pascal, Basic 
and some dabblings with assemblers of various breeds. Mostly, my adjustment has been
about doing things the way R likes; turning loop-ish code into vector-ish code, using
the right base functions properly and thinking about data in columns for a start.

Occasionally though, R has the capacity to make me doubt either its sanity, or
my own, at least for a while. Here are a couple of my lowest points. More may come later, but 
two is a start, and those PRs for [Hacktoberfest](https://hacktoberfest.digitalocean.com/) 
aren't going to happen on their own...

# The dodgy dollar?

Here is a piece of code, in which I incrementally ask my friends what their favourite
fruit is. I decided to use generic variable names, so that later on, I can maybe ask them
what's their favourite vegetable, or pet, or something. This sort of knowledge, I feel, is 
essential for being a good considerate colleague. I start writing some code to process
my friends' replies:-

```
data <- list()
data$thing_type <- "Fruit"

for (f in c("Apple", "Banana", "Cherry")) {
  data$thing <- c(data$thing, f)
}
```

So, now I can head to Tesco with a list of my colleague's favourite fruits.

```
> data$thing
[1] "Fruit"  "Apple"  "Banana" "Cherry"
```

Except... what's with the "Fruit" entry then? How did that get into my list of things? Even 
though I don't think I should need it, I instinctively put `data$thing <- NULL` as the 
second line. It makes no difference.

I restart RStudio, reboot my computer, update R - the usual sort of random flailing thing. 
All useless. I start to wonder if R has been tricking me all along, and I do some really
basic assignments and concatenations to check it's not been fatally flawed all these years. 
It appears fundamentally sound. 

Eventually, I ask my more R-experienced colleagues if, in fact, I am going insane. They
cannot answer this for sure, but looking at the programming issue, they tell me it is a 
feature of R in a way. 

The first time I read from `data$thing`, it doesn't exist 
in the list, and R auto-completes it into `data$thing_type` - hence the 
"Fruit". It doesn't auto-complete on the assignment side though, so after the first
loop iteration, `data$thing` exists, and things continue normally. 

It's tempting to think
`data$thing <- NULL` beforehand would help - but with a list, that
would only remove the (non-existent) `thing` from list, because that's what NULL assignment
with lists does.

So what should I instead do? One option is to replace my inner loop with
`data$thing <- c(data[['thing']], f)`, because the auto-completion is activated on the 
use of the dollar sign, but not on a quoted variable name. Moreover, setting these options:
```
warnPartialMatchAttr = TRUE
warnPartialMatchDollar = TRUE
warnPartialMatchArgs = TRUE
```
in `.Rprofile` will throw a warning every time R does a partial-match. This seems like
it might save a world of pain, although casting my mind back to various projects where I have
frivolously talked about `list$thing` and `list$thing_name` and `list$thing_id` still makes me
shudder a little. 

Also having set these options, I occasionally see warnings popping up about auto-completion
in code for other packages we rely upon...

## data.table vs data.frame

So I collected some more data for my colleagues, and I put it in a `data.frame` like this.
```
data <- data.frame(
  name = c("Alex", "Emma", "James", "Rich", "Rob"),
  food = c("Oysters", "Haggis", "Goose", "Cheese", "Celery"),
  stringsAsFactors = FALSE)

who_likes <- function(food) {
  data[data$food == food, ]
}
```

This is very nice. So if I have a haggis and wonder what to do with it[^1] :-
```
> who_likes("Haggis")
  name   food
2 Emma Haggis
```

Great. However, I later want to do something astoundingly complicated with this rich dataset, and I 
decide that using the popular [data.table](https://rdatatable.gitlab.io/data.table/) will 
be a good idea, since it's just a higher performance version of `data.frame`, right? It's
also in very common use. (To be clear, the performance increase is indeed very worthwhile for large
datasets).

However... if I edit just my first line from `data.frame(...)` to `data.table(...)` then...

```
> who_likes("Haggis")
  name    food
1 Alex Oysters
2 Emma  Haggis
3 James  Goose
4 Rich  Cheese
5 Rob   Celery
```

Now all my friends suddenly seem to like Haggis. And Cheese too. Or do they? A bit more exploring 
reveals that my friends in the `data.table` like absolutely everything in the universe. Even mushrooms.
And NULL too. This may or may not be true in reality, but it is definitely not what I wanted the subset to do.

What's happening is: when I write 
`data[data$food == food, ]`, then `data.table` interprets the right-hand `food` as being
the column in `data`, rather than the argument to `who_likes`. 
If instead I write:-

```
who_likes <- function(x) {
  data[data$food == x, ]
}
```

then all works as I expected. And if I (oddly) changed `x` to `name`, then data.table
would perform comparison between columns, returning zero rows.

Looking through my previous code I have quite a number of examples where the most natural
thing to write would be `data[data$country == country, ]` or `data[data$id == id, ]`. Luckily
I did so only with data-frames. I have not yet found any warnings I can switch on,
should I forget about this issue in the future. Again.

## Conclusions

Well. There are bumps in the road in any learning journey; these couple in R have been 
my two most notable ones. I think they are quite well known to more experienced R
programmers, who would probably acknowledge that they are a bit horrible, but easily
avoided once you know about them. Turning on the right warnings is a really good idea.

I am also thinking of reading [The R Inferno](https://www.burns-stat.com/pages/Tutor/R_inferno.pdf) by 
the perfectly named Patrick Burns. The preface begins "If you are using R and think
you're in hell, this is a map for you." I'm not sure I'd go quite that far in describing my 
experiences, but maybe being vaguely aware of some of the banana-skins in advance might be good
preparation to avoid some future diversions...

[^1]: Emma doesn't actually like haggis, and if I offered it, she would know _exactly_ what to do with it.