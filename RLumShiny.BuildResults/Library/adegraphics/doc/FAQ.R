## -----------------------------------------------------------------------------
set.seed(2564)
library(ade4)
library(adegraphics)

## -----------------------------------------------------------------------------
df <- data.frame(x = rep(1:10,1), 
                 y = rep(1:10, each = 10), 
                 ms_li = runif(100, min = -5, max = 4))
s.value(df[, 1:2], df$ms_li, 
        paxes.draw = TRUE)

## -----------------------------------------------------------------------------
s.value(df[, 1:2], df$ms_li, 
        paxes.draw = TRUE,
        xlab = "Longitude", xlab.cex = 0.5,
        ylab = "Latitude", ylab.cex = 0.5
        )

## -----------------------------------------------------------------------------
s.value(df[, 1:2], df$ms_li, 
        paxes.draw = TRUE,
        scales.x.cex = 0.5,
        scales.y.cex = 0.5
        )

## -----------------------------------------------------------------------------
s.value(df[, 1:2], df$ms_li, 
        paxes.draw = TRUE,
        xlab = "Longitude", xlab.cex = 2,
        ylab = "Latitude", ylab.cex = 2,
        layout.heights = list(bottom.padding = 2)
        )

## -----------------------------------------------------------------------------
x0 <- runif(50, -2, 2)
y0 <- runif(50, -2, 2)
s.label(data.frame(x0, y0))

## -----------------------------------------------------------------------------
s.label(data.frame(x0, y0), plabels.boxes.border = 0)
s.label(data.frame(x0, y0), plabels.boxes.draw = FALSE, ppoints.cex = 0)

## -----------------------------------------------------------------------------
s.label(data.frame(x0, y0), plabels.boxes.col = "orange")

## -----------------------------------------------------------------------------
s.label(data.frame(x0, y0), plabels.boxes.border = "blue", plabels.boxes.lwd = 2)

