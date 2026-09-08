# Explanation Rule (Explaining Technical Work to a Non-Implementer)

This is the shared standard for explaining technical work to a reader who will not implement it. Its one aim: when a run
has to tell someone what a change does, what a choice costs, or what would go wrong, that person can act on the answer
without opening the code.

The reader here is not a beginner. They may know the product better than you do. What they do not have is the code in
front of them, and they will not be the one writing it. Everything below follows from that.

## What this standard is not

This standard governs what a run says to a person in a turn. The
[readability rule](./readability-rule.md) governs the shape of a written deliverable.

They sit beside each other and neither replaces the other. A single run often needs both: the readability standard while
it drafts a specification, and this standard when it stops mid-run to ask the operator a question. Where the readability
rule gives you headings, paragraph structure, and a self-check over a whole document, this one gives you the
shape of one explanation inside one turn.

Two practical differences follow. This standard has no self-check, because a conversational turn is not a document you
review before shipping. And it says nothing about voice or vocabulary; the writing-voice profile still governs those
wherever it applies.

## Give a concrete outcome, not a mechanism

Describe something the reader could observe. Not the mechanism that produces it.

A mechanism is what you know and what you are tempted to say: the function that runs too early, the field that holds the
wrong type, the service that retries. An outcome is what the reader would see happen. The outcome is the part they can
weigh, and it is almost always shorter.

For a question shaped like data entry, the concrete outcome takes four parts:

1. **A named thing.** The box, the screen, the button, by the name it carries in the product.
2. **A real starting value.** Not "a value" or "some input". `12.50`.
3. **What the person enters or does.** The actual keystrokes or the actual click.
4. **The specific wrong result they would see.** The message, the number, the state, as they would encounter it.

Most explanations are not shaped like data entry, and the four-part form does not fit them. The general property still
holds: name something the reader could observe, in words from their own domain, in place of describing how the code gets
there.

## Never use shorthand the reader has not been given

A term counts as **unintroduced** when it appears in neither the work item nor this conversation. Do not use it, and do
not invent a name for a concept so you have something short to call it.

This test replaces a guess about what the reader knows with a check against what the run actually holds. You can run it:
search the work item, search the conversation, and if the term is in neither, it is unintroduced.

When you reach for an unintroduced term, you have found the place where a concrete outcome goes instead. The reaching is
the signal.

## Say the consequence before the detail

Lead with what happens. Put the technical reference below, or leave it out.

A reader who stops after your first sentence should still have the answer. A reader who wants the file and the line
number can read on and find it, and most of them will not want it.

## Worked example

The same explanation, written both ways.

```markdown
<!-- Mechanism first. The reader cannot act on this. -->
The coercion in the form object runs after validation, so the amount validator receives a String and
the numeric guard rejects it.

<!-- Outcome first. The reader can act on this. -->
Someone types 12.50 into the Amount box on a new entry and saves it. They get an error telling them the
amount is not a number.
```

Both sentences are true and describe the same defect. The second one is the one the reader can confirm, disagree with, or
make a decision about.

## How to apply this rule in a skill

Source the standard at the point where the run talks to a person, not at drafting time. In practice that means invoking
`han-communication:explanation-guidance` before writing an escalation, a confirmation turn, a stop, or any summary a
non-implementer reads.

The rule carries guidance only. There is no self-check step to add, so a skill that sources it gains no verification
pass. What follows from that is worth stating plainly: nothing observes whether the standard took effect. The evidence
that prompted it was escalations written in jargon, and a standard the escalating skills read while they draft is the
cheapest thing that answers it. If escalations still read as jargon once this is in place, a reviewing pass over
escalation prose becomes the next move.
