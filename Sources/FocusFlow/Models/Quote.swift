import Foundation

// MARK: - Quote Model

struct Quote: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let author: String

    init(id: UUID = UUID(), text: String, author: String) {
        self.id = id
        self.text = text
        self.author = author
    }

    // MARK: - Built-in Quote Library (50+ quotes)
    static let all: [Quote] = [
        // Deep Work & Focus
        Quote(text: "The successful warrior is the average man, with laser-like focus.", author: "Bruce Lee"),
        Quote(text: "Concentrate all your thoughts upon the work at hand. The sun's rays do not burn until brought to a focus.", author: "Alexander Graham Bell"),
        Quote(text: "It's not that I'm so smart, it's just that I stay with problems longer.", author: "Albert Einstein"),
        Quote(text: "That's been one of my mantras — focus and simplicity. Simple can be harder than complex.", author: "Steve Jobs"),
        Quote(text: "The difference between successful people and very successful people is that very successful people say no to almost everything.", author: "Warren Buffett"),
        Quote(text: "Where focus goes, energy flows.", author: "Tony Robbins"),
        Quote(text: "You will never reach your destination if you stop and throw stones at every dog that barks.", author: "Winston Churchill"),
        Quote(text: "The key is not to prioritize what's on your schedule, but to schedule your priorities.", author: "Stephen Covey"),
        Quote(text: "Deep work is the ability to focus without distraction on a cognitively demanding task.", author: "Cal Newport"),
        Quote(text: "Your future is created by what you do today, not tomorrow.", author: "Robert Kiyosaki"),

        // Stoic Philosophy
        Quote(text: "You have power over your mind, not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius"),
        Quote(text: "Waste no more time arguing about what a good man should be. Be one.", author: "Marcus Aurelius"),
        Quote(text: "The impediment to action advances action. What stands in the way becomes the way.", author: "Marcus Aurelius"),
        Quote(text: "We suffer more in imagination than in reality.", author: "Seneca"),
        Quote(text: "Begin at once to live, and count each separate day as a separate life.", author: "Seneca"),
        Quote(text: "It is not that I'm so smart. But I stay with the questions much longer.", author: "Epictetus"),
        Quote(text: "Make the best use of what is in your power, and take the rest as it happens.", author: "Epictetus"),
        Quote(text: "He who fears death will never do anything worthy of a living man.", author: "Seneca"),
        Quote(text: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius"),
        Quote(text: "If it is not right, do not do it; if it is not true, do not say it.", author: "Marcus Aurelius"),

        // Achievement & Effort
        Quote(text: "Do the hard work, especially when you don't feel like it.", author: "Seth Godin"),
        Quote(text: "Either you run the day, or the day runs you.", author: "Jim Rohn"),
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(text: "All our dreams can come true, if we have the courage to pursue them.", author: "Walt Disney"),
        Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
        Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        Quote(text: "Act as if what you do makes a difference. It does.", author: "William James"),
        Quote(text: "Strive not to be a success, but rather to be of value.", author: "Albert Einstein"),
        Quote(text: "You don't have to be great to start, but you have to start to be great.", author: "Zig Ziglar"),

        // Mindfulness & Presence
        Quote(text: "The present moment is the only moment available to us, and it is the door to all moments.", author: "Thich Nhat Hanh"),
        Quote(text: "Be here now.", author: "Ram Dass"),
        Quote(text: "In today's rush we all think too much, seek too much, want too much and forget about the joy of just being.", author: "Eckhart Tolle"),
        Quote(text: "Wherever you are, be all there.", author: "Jim Elliot"),
        Quote(text: "Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.", author: "Buddha"),
        Quote(text: "With the new day comes new strength and new thoughts.", author: "Eleanor Roosevelt"),
        Quote(text: "Energy and persistence conquer all things.", author: "Benjamin Franklin"),
        Quote(text: "Genius is 1% inspiration and 99% perspiration.", author: "Thomas Edison"),
        Quote(text: "Nothing in the world can take the place of persistence.", author: "Calvin Coolidge"),
        Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela"),

        // Creativity & Growth
        Quote(text: "Creativity is intelligence having fun.", author: "Albert Einstein"),
        Quote(text: "The mind that opens to a new idea never returns to its original size.", author: "Albert Einstein"),
        Quote(text: "Growth and comfort do not coexist.", author: "Ginni Rometty"),
        Quote(text: "What you do today can improve all your tomorrows.", author: "Ralph Marston"),
        Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
        Quote(text: "Hard work beats talent when talent doesn't work hard.", author: "Tim Notke"),
        Quote(text: "The expert in anything was once a beginner.", author: "Helen Hayes"),
        Quote(text: "Quality is not an act, it is a habit.", author: "Aristotle"),
        Quote(text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.", author: "Aristotle"),
        Quote(text: "Great things are done by a series of small things brought together.", author: "Vincent van Gogh"),
        Quote(text: "One step at a time is all it takes to get you there.", author: "Emily Dickinson"),
        Quote(text: "A year from now you may wish you had started today.", author: "Karen Lamb"),
    ]
}

