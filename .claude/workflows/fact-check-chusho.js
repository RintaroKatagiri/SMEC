
export const meta = {
  name: 'fact-check-chusho',
  description: '中小企業経営・中小企業政策ノートのファクトチェック（修正なし・誤り指摘のみ）',
  phases: [
    { title: 'ファイル読み取り・チェック' },
    { title: '統合レポート' },
  ],
}

const FILES = [
  "第一次試験/中小企業経営・中小企業政策/その他.md",
  "第一次試験/中小企業経営・中小企業政策/ものづくり補助金.md",
  "第一次試験/中小企業経営・中小企業政策/エクイティ・ファイナンスに関する基礎知識.md",
  "第一次試験/中小企業経営・中小企業政策/下請中小企業振興法.md",
  "第一次試験/中小企業経営・中小企業政策/中小PIM支援メニュー.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業・小規模事業者人材活用ガイドライン.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業倒産防止共済制度.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業基本法.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業退職金共済制度.md",
  "第一次試験/中小企業経営・中小企業政策/参考問題6年度_年度差し替え対策.md",
  "第一次試験/中小企業経営・中小企業政策/小規模事業者経営改善資金融資制度.md",
  "第一次試験/中小企業経営・中小企業政策/成長型中小企業等研究開発支援事業.md",
  "第一次試験/中小企業経営・中小企業政策/物資の流通の効率化に関する法律.md",
  "第一次試験/中小企業経営・中小企業政策/産業競争力強化法.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業省力化投資補助事業.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業白書・小規模企業白書.md",
  "第一次試験/中小企業経営・中小企業政策/下請代金支払遅延等防止法.md",
  "第一次試験/中小企業経営・中小企業政策/中小企業経営強化法.md",
  "第一次試験/中小企業経営・中小企業政策/高度化事業.md",
  "第一次試験/中小企業経営・中小企業政策/小規模企業共済制度.md",
]

const SCHEMA = {
  type: "object",
  properties: {
    file: { type: "string" },
    issues: {
      type: "array",
      items: {
        type: "object",
        properties: {
          severity: { type: "string", enum: ["誤り", "要注意", "補足推奨"] },
          location: { type: "string" },
          current: { type: "string" },
          correct: { type: "string" },
          explanation: { type: "string" }
        },
        required: ["severity", "location", "current", "correct", "explanation"]
      }
    }
  },
  required: ["file", "issues"]
}

phase('ファイル読み取り・チェック')

const results = await pipeline(
  FILES,
  async (filePath) => {
    const content = await agent(
      `以下のパスのファイルをReadツールで読み取り、内容をそのまま返してください。パス: ${filePath}`,
      { label: `read:${filePath.split('/').pop()}`, phase: 'ファイル読み取り・チェック', agentType: 'Explore' }
    )
    return { filePath, content }
  },
  async ({ filePath, content }) => {
    return agent(
      `あなたは中小企業診断士試験の専門家です。以下は「${filePath}」の学習ノートです。
内容を精査し、事実誤認・定義の誤り・数値の誤り・法令の誤り・制度の誤った説明などを見つけてください。

【チェック対象ノート内容】
${content}

【指示】
- 中小企業経営・中小企業政策は法令・制度の数値（金額・期間・人数・割合）が頻出論点のため、特に数値の正確性を厳しくチェックすること
- severity は「誤り」（明確に間違い）、「要注意」（曖昧・不正確）、「補足推奨」（不足があると誤解を招く）の3段階
- issues が空配列の場合は問題なし
- ファイル名は "${filePath}" を使用
- 中小企業診断士第一次試験の出題範囲・標準的な教科書・中小企業白書・各種法令に基づいて判断すること`,
      { label: `check:${filePath.split('/').pop()}`, phase: 'ファイル読み取り・チェック', schema: SCHEMA }
    )
  }
)

phase('統合レポート')

const allIssues = results.filter(Boolean).filter(r => r.issues && r.issues.length > 0)

const report = await agent(
  `以下は中小企業経営・中小企業政策ノートのファクトチェック結果です。各ファイルの問題点をまとめて、ユーザーに報告するレポートを日本語で作成してください。

【ファクトチェック結果JSON】
${JSON.stringify(allIssues, null, 2)}

【レポート形式】
- ファイル名ごとにセクション（### ファイル名）を作る
- 各問題点について：
  - severity（誤り／要注意／補足推奨）を先頭に明記
  - 場所（location）
  - 現在の記述（current）
  - 正しい内容（correct）
  - 説明（explanation）
- 「誤り」を最優先で示す
- 問題なしのファイルは触れなくてよい
- 末尾に「誤り」の総数と「要注意」の総数のサマリーを付ける
- 数値の誤りは特に強調すること（**太字**）`,
  { label: '統合レポート生成', phase: '統合レポート' }
)

return report
