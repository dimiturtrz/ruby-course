class Card
  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def rank
    @rank
  end

  def suit
    @suit
  end

  def to_s
    "#{@rank.is_a?(Symbol) ? @rank.capitalize : @rank} of #{@suit.capitalize}"
  end

  def ==(card)
    @rank == card.rank && @suit == card.suit
  end
end

module Deck
  include Enumerable
  def initialize(cards = false, suits = nil, ranks = nil)
    @suits = suits
    @ranks = ranks
    @deck = cards ? cards : @ranks.product(@suits).map{|combination|
                              Card.new(combination.first, combination.last)}
  end

  def size
    @deck.size
  end

  def draw_top_card
    @deck.shift
  end

  def draw_bottom_card
    @deck.pop
  end

  def top_card
    @deck.first
  end

  def bottom_card
    @deck.last
  end

  def shuffle
    @deck.shuffle!
  end

  def sort
    @deck.sort_by!{|card| [@suits.index(card.suit), - @ranks.index(card.rank)]}
  end

  def each
    @deck.each{|card| yield card}
  end

  def to_s
    @deck.map(&:to_s).join("\n")
  end

  def deal(hand_size, deck_class, ranks = @ranks, suits = @suits)
    deck_class.new(@deck.shift(hand_size), ranks, suits)
  end
end

module Hand
  def initialize(cards, ranks, suits)
    @cards = cards
    @suits = suits
    @ranks = ranks
  end

  def size
    @cards.size
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  def check_each_suit_in_hand_if(suits)
    suits.each do |suit|
      suit_in_hand_ranks = @cards.select{|card| card.suit == suit}.map(&:rank)
      return true if yield suit_in_hand_ranks
    end
    false
  end
end

class WarDeck
  include Deck
  HAND_CARDS = 26

  def initialize(cards = false)
    ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
    suits = [:spades, :hearts, :diamonds, :clubs]
    super cards, suits, ranks
  end

  def deal
    super HAND_CARDS, WarHand
  end
end

class WarHand
  include Hand
  def play_card
    @cards.delete_at(rand(@cards.size))
  end

  def allow_face_up?
    @cards.size <= 3
  end
end

class BeloteDeck
  include Deck
  HAND_CARDS = 8

  def initialize(cards = false)
    ranks = [7, 8, 9, :jack, :queen, :king, 10, :ace]
    suits = [:spades, :hearts, :diamonds, :clubs]
    super cards, suits, ranks
  end

  def deal
    super HAND_CARDS, BeloteHand
  end
end

class BeloteHand
  include Hand

  def highest_of_suit(suit)
    @cards.select{|card| card.suit == suit}.max_by{|card|
      @ranks.index(card.rank)}
  end

  def belote?
    check_each_suit_in_hand_if(@suits) do |suit_in_hand_ranks|
      ([:queen, :king] - suit_in_hand_ranks).empty?
    end
  end

  def same_suit_consecutive_cards cards_number
    check_each_suit_in_hand_if(@suits) do |suit_in_hand_ranks|
      @ranks.each_cons(cards_number).map{|sequence|
        sequence - suit_in_hand_ranks}.any?(&:empty?)
    end
  end

  def tierce?
    same_suit_consecutive_cards 3
  end

  def quarte?
    same_suit_consecutive_cards 4
  end

  def quint?
    same_suit_consecutive_cards 5
  end

  def carre_of rank
    @cards.map(&:rank).select{|card_rank| card_rank == rank}.count == 4
  end

  def carre_of_jacks?
    carre_of :jack
  end

  def carre_of_nines?
    carre_of 9
  end

  def carre_of_aces?
    carre_of :ace
  end
end

class SixtySixDeck
  include Deck
  HAND_CARDS = 6

  def initialize(cards = false)
    ranks = [9, :jack, :queen, :king, 10, :ace]
    suits = [:spades, :hearts, :diamonds, :clubs]
    super cards, suits, ranks
  end

  def deal
    @hand = super HAND_CARDS, SixtySixHand
  end
end

class SixtySixHand
  include Hand
  def same_suit_king_and_queen?(suits)
    check_each_suit_in_hand_if(suits) do |suit_in_hand_ranks|
      ([:queen, :king] - suit_in_hand_ranks).empty?
    end
  end

  def twenty?(trump_suit)
    suits = @suits.reject{|suit| suit == trump_suit}
    same_suit_king_and_queen?(suits)
  end

  def forty?(trump_suit)
    suits = [trump_suit]
    same_suit_king_and_queen?(suits)
  end
end
