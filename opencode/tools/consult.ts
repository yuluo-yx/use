import { tool } from "@opencode-ai/plugin"

export default tool({
  description:
    "Get a second opinion from another model. Provide full context and your question.",
  args: {
    context: tool.schema
      .string()
      .describe(
        "Full context: conversation summary, code snippets, options being considered, tradeoffs, etc."
      ),
    question: tool.schema
      .string()
      .describe("What you want the other model to weigh in on"),
  },
  async execute(args) {
    const prompt = `You are providing a second opinion with a slightly critical eye. Review this context and help with the question. Don't just agree - look for potential issues, edge cases, or alternative approaches that may have been missed.

## Context
${args.context}

## Question
${args.question}

Provide your analysis and recommendation.`

    const proc = Bun.spawn(["opencode", "run", "-m", "openai/gpt-5.4-mini"], {
      stdin: "pipe",
      stdout: "pipe",
      stderr: "pipe",
    })
    proc.stdin.write(prompt)
    proc.stdin.end()

    const output = await new Response(proc.stdout).text()
    await proc.exited
    return output
  },
})