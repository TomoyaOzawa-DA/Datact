library(ggplot2)
library(tidyverse)

# 評価値行列の作成
rating.mtx <-
  matrix(
    c(5, 3, 4, 2, NA,
      3, 1, 2, 3, 3,
      4, 3, 4, 2, 5,
      3, 3, 1, 5, 4,
      1, 5, 5, 2, 1
    )
    ,nrow=5
    ,byrow=TRUE
  )

# 行・列ラベル付与
row.lbl <- c("鈴木さん", "ユーザ1", "ユーザ2", "ユーザ3", "ユーザ4")
col.lbl <- c("作品1", "作品2", "作品3", "作品4", "ダークナイト")
dimnames(rating.mtx) <- list(row.lbl, col.lbl)

# プロットのための整形（wide -> long）
rating.mtx.p <-
  rating.mtx %>%
  as.data.frame() %>%
  tibble::rownames_to_column("userId") %>%
  tidyr::gather(key="movieId", value="rating", -userId) %>%
  dplyr::mutate(userId=factor(userId, levels=row.lbl[5:1]), movieId=factor(movieId, levels=col.lbl))

# プロット（ヒートマップ）
(g <- ggplot(rating.mtx.p,
             aes(movieId, userId)) +
    geom_tile(aes(fill=rating)) +
    geom_text(aes(label = rating), color="gray30") +
    scale_fill_gradient(low="white",high="orange", na.value = "gray90"))

# 類似度行列の計算
sim.mtx <- as(1/(dist(x=rating.mtx[,1:4], method = "euclidean", upper=TRUE, diag=TRUE)), 'matrix')

# 鈴木さんと他のユーザの類似度のみ表示
print(sim.mtx[,"鈴木さん",drop=FALSE])

# 鈴木さんに対する類似度を抽出（鈴木さん自身との類似度は除外）
sim.suzuki <- sim.mtx[rownames(sim.mtx) != "鈴木さん","鈴木さん"]

# 類似度の最も高い3人を選出(k=3)
NN.row.num <- head(order(sim.suzuki, decreasing=TRUE), n=3)
(NN <- names(sim.suzuki)[NN.row.num])

# >[1] "ユーザ2" "ユーザ1" "ユーザ4"

# ダークナイトの評価値を推定（加重平均）
(sum(rating.mtx[NN,"ダークナイト"] * sim.suzuki[NN]) / sum(sim.suzuki[NN]))
