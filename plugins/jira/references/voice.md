# Ticket Voice

The voice for every `dd:jira` text: titles, descriptions, comments. Read it before you write a draft. A teammate reads the ticket on the board, often weeks later, and English may be their second language. Write so they understand it on the first pass.

## Tone

- **Technical, not promotional.** No hype, no buzzwords. Banned: seamless, robust, powerful, leverage, streamline, cutting-edge.
- **Say it once.** No preamble ("This ticket is about…"), no recap at the end.
- **No hedging.** ✅ "The server drops the batch." ❌ "The server may possibly drop the batch." An open question goes in Info as a question, not as soft words.
- **Only facts the reader cannot get elsewhere.** Give a pointer, not a lesson on how the system works.

## Sentence shape — ASD-STE100

Write every sentence in Simplified Technical English (ASD-STE100). The title follows the same rules, but it is a phrase, not a sentence.

- **One idea per sentence.** Max 20 words for a step, 25 for a description. Split a long sentence. Never drop a causal link to fit the number — write more sentences, not fewer ideas.
- **Active voice: name the actor.** ✅ "The server sends the batch pubdata to the DA service." ❌ "The pubdata is sent to the DA service." A DoD bullet states an end state, so "The prover image is published." is correct there.
- **The imperative for a step.** ✅ "Run the upgrade on a devnet." One step per sentence.
- **Simple tenses only.** Present, past, or future with "will". No "-ing" verb: ✅ "The job runs." ❌ "The job is running."
- **One word per meaning.** Pick a term and use it in the title, the body and the DoD. ❌ "the e2e repo" → "the test repo" → "the harness repo".
- **The simplest precise word.** "use" not "utilize", "start" not "initiate", "so" not "in order to", "cut" not "condense". If the plain word keeps your meaning, use it.
- **No idioms, no phrasal verbs.** "start" not "kick off", "finish" not "wrap up", "delete" not "get rid of", "find" not "figure out".
- **Keep the articles.** ✅ "The devnet runs protocol v0.31.1." ❌ "Devnet runs protocol v0.31.1."
- **A list for three or more items, or for a sequence.** Use bullets for a set, numbers for an order.
- **Technical terms stay exact.** Versions, contract names, commands and error codes keep their real spelling, in backticks. Simplify the sentence, not the term.

## Check before you show the draft

Read each sentence once against this list:
- a passive verb hides the actor → name the actor;
- more than 25 words → split the sentence;
- a new word for a term you already used → use the first term;
- a phrasal verb or an idiom → use one plain verb;
- an "-ing" verb → use a simple tense.
