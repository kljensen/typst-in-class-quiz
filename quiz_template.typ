#let quiz(
  title: none,
  margin: 1cm,
  date: none,
  options: "ABCDE",
  text_size: 10pt,
  doc,
) = {

  // As we process questions, we will increment
  // this counter. We'll need this to assemble
  // an array of correct answers and also to print
  // an answer key with the correct number of rows.
  let question_number = counter("question_number")
  question_number.update(0)

  // This is an array of arrays. Each sub-array has
  // the correct answers for a question.
  let correct_answers = state("correct_answers", ())

  // Function for printing the answer key
  // at the end of the quiz.
  let answer_key() = {
    let data = correct_answers.get().enumerate().map(((i, answer)) => {
      let question = i + 1
      let options = answer.map(o => {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(o - 1)
      }).join(", ")
      return ([#question], [#options])
    }).flatten()
    table(columns: 2, ..data)
  }

  // The top-level enum is the quiz: an ordered list
  // of questions.
  show enum.where(tight: false): it => {
    // Iterate over the questions, each of which
    // is an enum_item.
    it.children
      .enumerate()
      .map(((n, item)) => {

        // Initialize the correct answers for this
        // question as an empty array.
        correct_answers.update( a => {
          a.push(())
          return a
        })

        // This counter will be used to keep track of
        // the options (potential answers) for this
        // question. Each option should but markdown
        // checkbox like
        let option_number = counter("option_number")
        option_number.update(0)

        // These are the incorrect options.
        // Remove the "[ ]"
        show "[ ]": unchecked => {
          ""
        }

        // These are the correct options. We need
        // to record these as cof
        show "[x]": checked => {

          // Record the correct answer for this question.
          context {
              let qn = question_number.get().first()
              let on = option_number.get().first()
              // Append this option number to the array
              // of correct options for this question
              // number.
              correct_answers.update( a => {
                  a.at(qn - 1).push(on)
                return a
              })
            }
          ""
        }
        // The question options are lists but not enums.
        // We want them to display as enums with letters.
        show list: el => {
          enum(
            numbering: (it => strong[#numbering("A.", it)]),
            ..el.children.map(it => {
            option_number.step()
            it.body
          }))
        }
        // Increment the question number.
        question_number.step()

        let number = [
          #set align(right)
          #numbering("1.", n + 1)
        ]

        // And return the question body.
        grid(
          columns: (1em, 1fr),
          gutter: .5em,
          number,
          item.body,
        )
      })
      .join()
  }

  // --------------------------------------------
  // First page: instructions and answer bubbles
  // --------------------------------------------

  // Title and date
  set page(margin: 1.5in)
  set align(center)
  text(17pt, title)
  if date == none {
    date = datetime.today().display("[month repr:long] [day], [year]")
  }
  par(justify: false)[
    #date
  ]

  // Instructions
  set align(left)
  [== Instructions]
  rect(inset: 1em)[
    - Do not flip over this page or read the questions on the other side of this page until the start of class.
    - Your quiz will be collected after ten minutes.
    - Write your netid _clearly_ at the top right.
    - _Unless otherwise stated_, each question has one correct answer.
    - Fill in the appropriate bubble below. I will grade nothing but these bubbles. If you need to change an answer please indicate your final answer clearly.
    - If a question stinks, Kyle will fix it later. I will not answer questions during the quiz.
    - This quiz is closed book, closed device. You can only use your own meat computer.
    - When you're done, _raise your hand_ and an instructor will collect it.
  ]

  // Answer bubbles
  context {
    v(1cm)
    set align(center)
    box[
      == Answers
    ]
    v(0.25cm)

    let row_of_bubbles = options.clusters().map(c => {
      [#box(circle(inset: 2pt)[
        #set align(center)
        #set text(size: 8pt)
        #c
      ])]
    }).join(" ")

    let elements = ()
    let qn = 1
    let num_questions = question_number.final().first()
    while qn < num_questions + 1 {

      // Write the question number. We
      // shift this to align with bubbles.
      let label = box[
        #set align(right)
        #set text(baseline: 0.25em)
        #qn.
      ]
      elements.push(label)
      elements.push(row_of_bubbles)
      qn += 1
    }
    grid(
      columns: 2,
      gutter: .75em,
      ..elements
    )
  }
  pagebreak()


  // --------------------------------------------
  // Second page: quiz questions
  // --------------------------------------------
  {
    set page(
      columns: 2,
      margin: margin,
    )
    set text(size: text_size)

    // This is the document body that is received
    // as the final argument to the quiz template.
    doc
    pagebreak()
  }

  // --------------------------------------------
  // Third page: answer key
  // --------------------------------------------
  {
    set align(center)
    [== Answer Key]
    context[
      #answer_key()
    ]
  }

}
