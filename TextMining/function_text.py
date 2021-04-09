def make_network(list_data, part_of_speech, size):
    
    output = []
    
    for sentence in list_data:
        t = Tokenizer()
        text = sentence
        result = t.tokenize(text)
        
        words = []
    
        for token in result:
            pos = token.part_of_speech.split(',')[0]
            if pos in part_of_speech:
                words.append(token.base_form)

        output.append(words)

    # 文単位の名詞ペアリストを生成
    pair_list = [
                 list(itertools.combinations(n, 2))
                 for n in output if len(output) >=2
                 ]

    # 名詞ペアリストの平坦化
    all_pairs = []
    for u in pair_list:
        all_pairs.extend(u)

    # 名詞ペアの頻度をカウント
    cnt_pairs = Counter(all_pairs)
    
    tops = sorted(
    cnt_pairs.items(), 
    key=lambda x: x[1], reverse=True
    )[:size]
    
    noun_1 = []
    noun_2 = []
    frequency = []

    # データフレームの作成
    for n,f in tops:
        noun_1.append(n[0])    
        noun_2.append(n[1])
        frequency.append(f)

    df = pd.DataFrame({'前出名詞': noun_1, '後出名詞': noun_2, '出現頻度': frequency})

    # 重み付きデータの設定
    weighted_edges = np.array(df)
    
    # グラフオブジェクトの生成
    G = nx.Graph()

    # 重み付きデータの読み込み
    G.add_weighted_edges_from(weighted_edges)

    # ネットワーク図の描画
    plt.figure(figsize=(10,10))
    nx.draw_networkx(G,
                     node_color = "c", 
                     node_size = 1000,
                     edge_color = "gray", 
                     font_family = "IPAexGothic") # フォント指定

    plt.show()