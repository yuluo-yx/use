# Voice Prompt

@description Record speech from microphone, transcribe, and optimize into a prompt.

Call the MCP tool `voice_prompt_optimize` with these defaults:
- `return_transcript`: true
- `duration_seconds`: 0 (stop with Enter)

If the user provides arguments, pass them through:
- `$ARGUMENTS` as `instruction`

After the tool returns, treat the optimized prompt as the user's next request and execute it immediately. Do not ask for confirmation.

If the tool fails with a TTY error, retry with `duration_seconds: 30`.
