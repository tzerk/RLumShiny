### R code from vignette source 'intro-vegan.Rnw'

###################################################
### code chunk number 1: intro-vegan.Rnw:18-23
###################################################
par(mfrow=c(1,1))
options(width=72)
figset <- function() par(mar=c(4,4,1,1)+.1)
options(SweaveHooks = list(fig = figset))
options("prompt" = "> ", "continue" = "  ")


###################################################
### code chunk number 2: intro-vegan.Rnw:73-76
###################################################
library(vegan)
data(dune)
ord <- decorana(dune)


###################################################
### code chunk number 3: intro-vegan.Rnw:79-80
###################################################
ord


###################################################
### code chunk number 4: intro-vegan.Rnw:103-105
###################################################
ord <- metaMDS(dune, trace = FALSE)
ord


###################################################
### code chunk number 5: a
###################################################
plot(ord)


###################################################
### code chunk number 6: intro-vegan.Rnw:120-121
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(ord)


###################################################
### code chunk number 7: a
###################################################
plot(ord, type = "n")
points(ord, display = "sites", cex = 0.8, pch=21, col="red", bg="yellow")
text(ord, display = "species", cex=0.7, col="blue")


###################################################
### code chunk number 8: intro-vegan.Rnw:142-143
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(ord, type = "n")
points(ord, display = "sites", cex = 0.8, pch=21, col="red", bg="yellow")
text(ord, display = "species", cex=0.7, col="blue")


###################################################
### code chunk number 9: intro-vegan.Rnw:151-154
###################################################
plot(ord, type = "n") |>
points("sites", cex = 0.8, pch=21, col="red", bg="yellow") |>
text("species", cex=0.7, col="blue")


###################################################
### code chunk number 10: intro-vegan.Rnw:226-228
###################################################
data(dune.env)
attach(dune.env)


###################################################
### code chunk number 11: a
###################################################
plot(ord, disp="sites", type="n")
ordihull(ord, Management, col=1:4, lwd=3)
ordiellipse(ord, Management, col=1:4, kind = "ehull", lwd=3)
ordiellipse(ord, Management, col=1:4, draw="polygon")
ordispider(ord, Management, col=1:4, label = TRUE)
points(ord, disp="sites", pch=21, col="red", bg="yellow", cex=1.3)


###################################################
### code chunk number 12: intro-vegan.Rnw:239-240
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(ord, disp="sites", type="n")
ordihull(ord, Management, col=1:4, lwd=3)
ordiellipse(ord, Management, col=1:4, kind = "ehull", lwd=3)
ordiellipse(ord, Management, col=1:4, draw="polygon")
ordispider(ord, Management, col=1:4, label = TRUE)
points(ord, disp="sites", pch=21, col="red", bg="yellow", cex=1.3)


###################################################
### code chunk number 13: intro-vegan.Rnw:270-272
###################################################
ord.fit <- envfit(ord ~ A1 + Management, data=dune.env, perm=999)
ord.fit


###################################################
### code chunk number 14: a
###################################################
plot(ord, dis="site")
plot(ord.fit)


###################################################
### code chunk number 15: b
###################################################
ordisurf(ord, A1, add=TRUE)


###################################################
### code chunk number 16: intro-vegan.Rnw:288-290
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(ord, dis="site")
plot(ord.fit)
ordisurf(ord, A1, add=TRUE)


###################################################
### code chunk number 17: intro-vegan.Rnw:310-312
###################################################
ord <- cca(dune ~ A1 + Management, data=dune.env)
ord


###################################################
### code chunk number 18: a
###################################################
plot(ord)


###################################################
### code chunk number 19: intro-vegan.Rnw:319-320
###################################################
getOption("SweaveHooks")[["fig"]]()
plot(ord)


###################################################
### code chunk number 20: intro-vegan.Rnw:337-338
###################################################
cca(dune ~ ., data=dune.env)


###################################################
### code chunk number 21: intro-vegan.Rnw:347-348
###################################################
anova(ord)


###################################################
### code chunk number 22: intro-vegan.Rnw:356-357
###################################################
anova(ord, by="term", permutations=199)


###################################################
### code chunk number 23: intro-vegan.Rnw:362-363
###################################################
anova(ord, by="mar", permutations=199)


###################################################
### code chunk number 24: a
###################################################
anova(ord, by="axis", permutations=499)


###################################################
### code chunk number 25: intro-vegan.Rnw:375-377
###################################################
ord <- cca(dune ~ A1 + Management + Condition(Moisture), data=dune.env)
ord


###################################################
### code chunk number 26: intro-vegan.Rnw:382-383
###################################################
anova(ord, by="term", permutations=499)


###################################################
### code chunk number 27: intro-vegan.Rnw:391-393
###################################################
how <- how(nperm=499, plots = Plots(strata=dune.env$Moisture))
anova(ord, by="term", permutations = how)


###################################################
### code chunk number 28: intro-vegan.Rnw:397-398
###################################################
detach(dune.env)


