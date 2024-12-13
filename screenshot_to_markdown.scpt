try
    set {tempFolder, tempPath, apiURL} to {¬
        do shell script "echo $TMPDIR", ¬
        (do shell script "echo $TMPDIR") & "temp_screenshot.png", ¬
        "<YOUR API URL>" ¬
    }
    
    -- スクリーンショット取得（選択範囲指定モード）
    do shell script "screencapture -i " & quoted form of tempPath
    
    -- スクリーンショットが取得されたか確認
    set fileExists to do shell script "[ -f " & quoted form of tempPath & " ] && echo 'yes' || echo 'no'"
    if fileExists is "no" then
        error "スクリーンショットの取得に失敗しました。選択範囲の指定をキャンセルした可能性があります。"
    end if
    
    -- 画像をリサイズ
    do shell script "sips -Z 600 " & quoted form of tempPath
    
    -- 画像をbase64エンコード（標準入力から読み込み）
    set base64Data to do shell script "base64 < " & quoted form of tempPath
    
    -- JSONデータの作成
    set jsonData to "{\"image\":\"" & base64Data & "\"}"
    
    -- curlでPOSTリクエストを実行
    set curlCommand to "curl -L -H \"Content-Type: application/json\" -d " & quoted form of jsonData & " " & apiURL
    
    -- リクエスト実行と結果取得
    set response to ""
    try
        set response to do shell script curlCommand
        
        -- レスポンスが空でないかチェック
        if response is "" then
            error "APIからのレスポンスが空です。"
        end if
        
        -- レスポンスをクリップボードにコピー
        set the clipboard to response
        
        -- 成功通知
        display notification "Markdownをクリップボードにコピーしました。" with title "変換成功" sound name "Glass"
        
    on error errorMessage
        error "APIリクエストに失敗しました。: " & errorMessage
    end try
    
    -- 一時ファイルの削除
    do shell script "rm -f " & quoted form of tempPath
    
on error errorMessage
    -- エラー通知
    display notification "エラーが発生しました: " & errorMessage with title "エラー" sound name "Basso"
end try
