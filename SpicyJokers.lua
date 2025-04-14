--- STEAMODDED HEADER
--- MOD_NAME: SpicyJokers
--- MOD_ID: SpicyJokers
--- MOD_AUTHOR: [Toasterobot]
--- MOD_DESCRIPTION: This mod adds 20 New jokers with unique art
--- PREFIX: ssj
--- BADGE_COLOUR: 8B52A9
--- VERSION: 0.2.1
----------------------------------------------
------------MOD CODE -------------------------

local config = {

    debug = false;

}
G.localization.misc.dictionary["k_lucky"] = "Lucky"


local seven = false;
local usedConsumables = {};

SMODS.Atlas{
    key = "spicy_jokers",
    path = "sprites.png",
    px = 71,
    py = 95,
}

------------- JOKERS -------------------------

-- Edward Gun
SMODS.Joker{
    name = "Edward Gun",
    key = "gun_joker",
    loc_txt = { 
        name = "Edward Gun",
        text = {
            "{X:red,C:white}X#1#{} Mult on {C:attention}first",
            "{C:attention}hand{} of round"
        },
    },
    config = {
        extra = 3
    },
    pos = {x = 0, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 6,
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra}} end,
    blueprint_compat = true,
    eternal_compat = true,
    discovered = true,

    calculate = function(self, card, context)
        if context.joker_main and G.GAME.current_round.hands_played == 0 then
            return {
                message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra}},
                Xmult_mod = card.ability.extra
            }
        end
    end,
    
    atlas = "spicy_jokers",

}
SMODS.Joker{
    name = "Lucky Seven",
    key = 'lucky_seven',
    loc_txt = { 
        name = "Lucky Seven",
        text = {
            "All Scored cards played with a {C:attention}7{}",
            "become {C:attention}Lucky{} cards"
        },
    },
    
    pos = {x = 1, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.before and  context.cardarea == G.jokers then
            seven = false;
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:get_id() == 7 then seven = true end
            end
        end
        if not context.repetition and not context.other_joker and context.cardarea == G.jokers and context.before then
            if seven then
                for k, v in ipairs(context.scoring_hand) do
                    v:set_ability(G.P_CENTERS.m_lucky, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            v:juice_up()
                            return true
                        end
                    })) 
                end
                return {
                    message = localize('k_lucky'),
                    colour = G.C.MONEY,
                    card = card
                }
            end
        end
    end
    }

SMODS.Joker{
        name = "Business Joker",
        key = 'business_joker',

        loc_txt = { 
            name = "Business Joker",
            text = {
                "Create a {C:attention}Hermit{} {C:tarot}Tarot{}",
            "if {C:attention}round won{}",
            "with only {C:chips}1{} hand",
            "{C:inactive}(Must have room)"
            },
        },
        pos = {x = 2, y = 0}, -- POSITION IN SPRITE SHEET
        rarity = 1,
        cost = 4,
        blueprint_compat = true,
        eternal_compat = false,
        discovered = true,
        atlas = "spicy_jokers",
        calculate = function(self, card, context)
            if G.GAME.current_round.hands_played == 0 and context.after and G.GAME.chips + hand_chips * mult > G.GAME.blind.chips then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.2,
                        func = (function()
                            (context.blueprint_card or card):juice_up(0.8, 0.8)
                                local c = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_hermit', 'sup')
                                c:add_to_deck()
                                G.consumeables:emplace(c)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Hermit", colour = G.C.PURPLE})
                    end
            end
        end

}
SMODS.Joker{
    name = "Sagittarius A*",
    key = 'void',
    loc_txt = { 
        name = "Sagittarius A*",
        text = {
            "When {C:attention}blind{} is selected,",
            "Create a {C:spectral}Black Hole{} card",
            "and {C:attention}destroy{} a random joker",
            "{C:inactive}(Must have room)"
        },
    },
    
    config = {
    },
    pos = {x = 3, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 5,
    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.setting_blind and not self.getting_sliced and not (context.blueprint_card or self).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            local destructable_jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= self and not G.jokers.cards[i].ability.eternal and not G.jokers.cards[i].getting_sliced then destructable_jokers[#destructable_jokers+1] = G.jokers.cards[i] end
            end
            local joker_to_destroy = #destructable_jokers > 0 and pseudorandom_element(destructable_jokers, pseudoseed('void')) or nil
            if joker_to_destroy and not (context.blueprint_card or self).getting_sliced then 
                joker_to_destroy.getting_sliced = true
                G.E_MANAGER:add_event(Event({func = function()
                    (context.blueprint_card or card):juice_up(0.8, 0.8)
                    joker_to_destroy:start_dissolve({G.C.PURPLE}, nil, 1.6)
                    local card = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_black_hole', 'sup')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                return true end }))
            end
        end
    end

}
SMODS.Joker{
    name = "Joker Squad",
    key = 'joker_squad',
    loc_txt = { 
        name = "Joker Squad",
        text = {
            "{C:chips}+30{} Chips for,",
            "each {C:attention}Joker{} card",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)"
        },
    },
    pos = {x = 4, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 3,
    config = {
        extra = 30
    },
    loc_vars = function(self, info_queue, card) return {vars = {(G.jokers and G.jokers.cards and #G.jokers.cards or 0)*30}} end,

    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.joker_main then
            local x = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].ability.set == 'Joker' then 
                    x = x + 1 
                end
            end
            return {
                message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra * x}},
                chip_mod = card.ability.extra * x, 
                colour = G.C.CHIPS
            }
        end
    end

}
SMODS.Joker{
    name = "Antimatter Joker",
    key = 'antimatter_joker',
    desc = {
        "{C:dark_edition}+2{} Joker Slots"
    },
    loc_txt = { 
        name = "Antimatter Joker",
        text = {
            "{C:dark_edition}+2{} Joker Slots"
        },
    },
    pos = {x = 5, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 3,
    cost = 10,
    config = {
    },
    blueprint_compat = false,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    add_to_deck = function(from_debuff)
        if G.jokers then
            G.jokers.config.card_limit = G.jokers.config.card_limit + 2
        end
    end,
    remove_from_deck = function(from_debuff)
        if G.jokers then
            G.jokers.config.card_limit = G.jokers.config.card_limit - 2
        end
    end
}
SMODS.Joker{
    name = "Misfire",
    key = 'misfire',
    loc_txt = { 
        name = "Misfire",
        text = {
            "{C:green}#1# in #2#{} chance for",
            "{X:red,C:white} X5 {} Mult"
        },
    },
    pos = {x = 6, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 4,
    config = { extra = 5
    },
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra}} end,
    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.joker_main then
            if pseudorandom('misfire') < G.GAME.probabilities.normal/card.ability.extra then
                return {
                    message = localize{type = 'variable', key = 'a_xmult',vars = {card.ability.extra}},
                    Xmult_mod = 5
                }
            end
        end
    end


}

SMODS.Joker{
    name = "Gnarled Throne",
    key = 'gnarled_throne',
    
    loc_txt = { 
        name = "Gnarled Throne",
        text = {
            "{C:mult}+1{} Mult for each",
            "card {C:attention}sold{} ",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)",
        },
    },
    pos = {x = 7, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 3,
    config = { extra = 0
    },
    loc_vars =function(self,info_queue,card) return {
        vars = {card.ability.extra}} end,
    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.selling_card then
            card.ability.extra = card.ability.extra +1
            G.E_MANAGER:add_event(Event({
                func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={card.ability.extra}}}); return true
                end}))
        end
        if context.joker_main and card.ability.extra > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra}},
                mult_mod = card.ability.extra,
                colour = G.C.MULT
            }
        end
    end
}

SMODS.Joker{
    name = "Shocked and Rattled",
    key = 'snr',
    loc_txt = { 
        name = "Shocked and Rattled",
        text = {
            "{C:mult}+5{} Mult for each",
            "{C:attention}#1#{} Discarded",
            "{C:attention}poker hand{} changes",
            "At the end of the round",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)",
        },
    },
    pos = {x = 8, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 4,
    config = { to_do_poker_hand = "High Card",extra = 0
    },
    loc_vars =function(self,info_queue, card) return {vars = {localize(card.ability.to_do_poker_hand, 'poker_hands'), card.ability.extra}} end,
    set_ability = function(self,card, initial, delay_sprites)
        local _poker_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if v.visible then _poker_hands[#_poker_hands+1] = k end
        end
        
        local old_hand = card.ability.to_do_poker_hand
        card.ability.to_do_poker_hand = nil
        while not card.ability.to_do_poker_hand do
            card.ability.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed("snr"))
            if card.ability.to_do_poker_hand == old_hand then card.ability.to_do_poker_hand = nil end
        end
    end,
    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.pre_discard then
            local text,disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            if disp_text == card.ability.to_do_poker_hand then
                card.ability.extra = card.ability.extra + 5
                G.E_MANAGER:add_event(Event({
                    func = function() card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={"SHOCKED"}}}); return true
                    end}))
            end
        end
        if context.joker_main and card.ability.extra > 0 then
            return {
                message = localize{type='variable',key='a_mult',vars={card.ability.extra}},
                mult_mod = card.ability.extra,
                colour = G.C.MULT
            }
        end
        if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
            local _poker_hands = {}
            for k, v in pairs(G.GAME.hands) do
                if v.visible then _poker_hands[#_poker_hands+1] = k end
            end
            
            local old_hand = card.ability.to_do_poker_hand
            card.ability.to_do_poker_hand = nil
            while not card.ability.to_do_poker_hand do
                card.ability.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed("snr"))
                if card.ability.to_do_poker_hand == old_hand then card.ability.to_do_poker_hand = nil end
            end
            return {
                message = card.ability.to_do_poker_hand
            }
        end
    end


}

SMODS.Joker{
    name = "Sisyphus",
    key = 'sus',
    loc_txt = { 
        name = "Sisyphus",
        text = {
            "Played {C:attention}Stone Cards{}",
            "give {X:red,C:white} X1.5{} Mult"
        },
    },
    pos = {x = 9, y = 0}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 3,
    config = { extra = 1.5
    },
        ---loc_vars =function(card) return { } end,
    
    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if   context.cardarea == G.play  and context.individual and context.other_card.ability.effect == "Stone Card" then
                    return {
                        x_mult = card.ability.extra,
                        card = card
                    }
                end
    end,
}

SMODS.Joker{
    name = "Roided Joker",
    key = 'roided',
    loc_txt = { 
        name = "Roided Joker",
        text = {
            "Sell this joker to create {C:attention}#1#{}",
            "{C:dark_edition}negative{} {C:attention}strength{} {C:tarot}tarot{} card(s)",
            "Increases at end of round"
        },
    },
    pos = {x = 0, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 2,
    config = { extra = 1
    },
    loc_vars =function(self,info_queue, card) return {vars = {card.ability.extra}} end,
    
    blueprint_compat = false,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.end_of_round and not (context.individual or context.repetition or context.blueprint) then
            card.ability.extra =card.ability.extra + 1
            return {
                message = localize('k_val_up')
            }
        end

        if context.selling_self then
            if card.ability.extra then
                for i = 1, card.ability.extra do
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local c = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_strength', 'sup')
                            c:set_edition({negative = true}, true)
                            c:add_to_deck()
                            G.consumeables:emplace(c)
                            return true
                        end}))
                end
            end
        end
    end 
}

SMODS.Joker{
    name = "Suicide King",
    key = 'suicide_king',
    loc_txt = { 
        name = "Suicide King",
        text = {
            "When round begins,",
            "add a glass{C:attention} King{} of {C:hearts}Hearts{}",
            "to your hand"
        },
    },
    pos = {x = 1, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 3,
    cost = 8,
    config = {},
    
    blueprint_compat = true,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            G.E_MANAGER:add_event(Event({
                func = function() 
                    local _card = create_playing_card({
                        front =  G.P_CARDS['H_K'], 
                        center = G.P_CENTERS.m_glass}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                    G.GAME.blind:debuff_card(_card)
                    G.hand:sort()
                    if context.blueprint_card then context.blueprint_card:juice_up() else card:juice_up() end
                    return true
                end}))
        end 
    end 
}

SMODS.Joker{
    name = "Razor Blade",
    key = 'razor_blade',
    loc_txt = { 
        name = "Razor Blade",
        text = {
            "When {C:attention}Blind{} is selected",
            "set discards to {C:red}1{}",
            "Discarded cards are destroyed",
        },
    },
    pos = {x = 2, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 8,
    config = {},
    
    blueprint_compat = false,
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if not (context.blueprint_card or card).getting_sliced and context.setting_blind then
            ease_discard(-G.GAME.current_round.discards_left + 1, nil, true)
        end
        if  not context.blueprint and context.discard then
            return {
                message = "Sharp",
                colour = G.C.MONEY,
                delay = 0.45, 
                remove = true,
                card = card
            }
        end
    end 
}

SMODS.Joker{
    name = "Double Barrel",
    key = 'double_barrel',
    loc_txt = { 
        name = "Double Barrel",
        text = {
            "{C:attention}Retrigger{} all",
           "{C:red}Red{} {C:attention}Seal cards{}"
        },
    },
    pos = {x = 3, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 8,
    config = {},
    
    blueprint_compat = true, -- MAke true later
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.repetition then
            
            if context.cardarea == G.play then -- Repeat for played cards
                if context.other_card:get_seal() == "Red" then 
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = card
                    }
                end
            end 

            if context.end_of_round then
                if context.cardarea == G.hand then -- Repeat for held cards at end of round (gold cards)
                    if context.other_card:get_seal() == "Red" and
                    (next(context.card_effects[1]) or #context.card_effects > 1) then
                        return {
                            message = localize('k_again_ex'),
                            repetitions = 1,
                            card = card
                        }
                    end
                end
            end

            if context.cardarea == G.hand then -- Repeat for held cards 
                if context.other_card:get_seal() == "Red" and
                (next(context.card_effects[1]) or #context.card_effects > 1) then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = 1,
                        card = card
                    }
                end
            end

        end 
    end 
}

SMODS.Joker{
    name = "Five Head",
    key = 'five_head',
    loc_txt = { 
        name = "Five Head",
        text = {
            "{C:chips}+#1#{} Chips for each",
            "played {C:attention}Hand{} of 5 cards",
            "Resets if {C:attention}Hand{} is not 5 cards",
            "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)"
        },
    },
    pos = {x = 4, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 4,
    config = {extra = {chips = 0, chip_mod = 7}},
    loc_vars =function(self,info_queue, card) return {vars = {card.ability.extra.chip_mod,card.ability.extra.chips }} end,
    blueprint_compat = true, -- MAke true later
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            if context.before then
                if #context.full_hand == 5 and not context.blueprint then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.CHIPS,
                        card = card
                    }
                end
                if #context.full_hand ~= 5 and not context.blueprint then
                    card.ability.extra.chips = 0
                    return {
                        card = card,
                        message = localize('k_reset')
                    }
                end
            end
        end 
        if context.joker_main then
            return {
                message = localize{type = 'variable', key = 'a_chips', vars = {card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips, 
                colour = G.C.CHIPS
            }
        end
    end 
}

SMODS.Joker{
    name = "Coffee",
    key = 'coffee',
    loc_txt = { 
        name = "Coffee",
        text = {
            "Upgrades played hand",
            "for the next {C:attention}#1#{} hands"
        },
    },
    pos = {x = 5, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 4,
    config = {extra = { hands_left = 4}},
    loc_vars =function(self,info_queue, card) return {vars = {card.ability.extra.hands_left}} end,
    blueprint_compat = true, -- MAke true later
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.cardarea == G.jokers then
            if card.ability.extra.hands_left == 0 and not card.getting_removed then
                card.getting_removed = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                    if G.jokers then
                                        local success, _ = pcall(function()
                                            if G.jokers:has_card(card) then
                                                G.jokers:remove_card(card)
                                                card:remove()
                                            end
                                        end)
                                        if not success and card and card.remove then
                                            card:remove()
                                        end
                                    end
                                return true; end})) 
                        return true
                    end
                })) 
                return {
                    message = "Drank",
                    colour = G.C.RED
                }
            end
            if context.before then
                card.ability.extra.hands_left = card.ability.extra.hands_left -1
                return {
                    card = card,
                    level_up = true,
                    message = localize('k_level_up_ex')
                }
            end
        end
    end
}

SMODS.Joker{
    name = "Negatron Don",
    key = 'nega',
    loc_txt = { 
        name = "Negatron Don",
        text = {
            "Sell this card to make",
            "{C:attention}joker{} to the right {C:dark_edition}negative{}",
            
        },
    },
    pos = {x = 6, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 2,
    cost = 10,
    blueprint_compat = false, 
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.selling_self then
            local other_joker = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i+1] end
            end

            if other_joker and other_joker ~= card then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    local edition = {negative = true}
                    other_joker:set_edition(edition, true)
                    card:juice_up(0.3, 0.5)
                return true end }))
            end
        end
    end
}

SMODS.Joker{
    name = "Hornet",
    key = 'hornet',
    loc_txt = { 
        name = "Hornet",
        text = {
            "{X:red,C:white}X#1#{} Mult",
            "{C:inactive}Shaw!!!{}",
            
        },
    },
    pos = {x = 7, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 3,
    config = {extra = 1.25},
    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra}} end,
    blueprint_compat = false, 
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra}},
                Xmult_mod = card.ability.extra
            }
        end
    end,
}

SMODS.Joker{
    name = "Shredded Joker",
    key = 'shredded',
    loc_txt = { 
        name = "Shredded Joker",
        text = {
                "{C:green}#1# in #2#{} chance to create",
                "a {C:tarot}Fool{} card when any",
                "{C:attention}consumable{} is used"
        },
    },
    pos = {x = 8, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 3,
    config = {extra = 4},
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra}} end,
    blueprint_compat = false, 
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.using_consumeable then
            if pseudorandom('shredded') < G.GAME.probabilities.normal/card.ability.extra then
                return {
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            local c = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_fool', 'sup')
                            c:add_to_deck()
                            G.consumeables:emplace(c)
                            return true
                        end}))
                }
            end
        end
    end,
}

SMODS.Joker{
    name = "obmiJ",
    key = 'obmij',
    loc_txt = { 
        name = "obmiJ",
        text = {
                "{C:attention}Swaps{} {C:mult}chips{} and {C:chips}mult{}",
        },
    },
    pos = {x = 9, y = 1}, -- POSITION IN SPRITE SHEET
    rarity = 1,
    cost = 3,
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra}} end,
    blueprint_compat = false, 
    eternal_compat = false,
    discovered = true,
    atlas = "spicy_jokers",
    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            hand_chips, mult = mult, hand_chips
            return {
                update_hand_text({delay = 0}, {chips = hand_chips}),
                update_hand_text({delay = 0.1}, {mult = mult}),
                message = "Swapped"
            }
        end
    end,
}

if config.debug then
    SMODS.Back{ 
        key = "test",
        name = "Test Deck",
        atlas = "spicy_jokers" , 
        pos = { x = 0, y = 0 }, 
        loc_txt = {
            name = "Test Deck",
            text = {
            "This is used for debugging/testing jokers",
            }
        },
        apply = function(back)
            G.E_MANAGER:add_event(Event({
                func = function()
                    add_joker("j_ssj_gun_joker", nil, false, false)
                    add_joker("j_ssj_suicide_king", nil, false, false)
                    add_joker("j_ssj_coffee", nil, false, false)
                    add_joker("j_ssj_hornet", nil, false, false)
                    add_joker("j_ssj_shredded", nil, false, false)
                    add_joker("j_ssj_nega", nil, false, false)
                    add_joker("j_ssj_obmij", nil, false, false)
                    local c = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_chariot', 'sup')
                    c:add_to_deck()
                    G.consumeables:emplace(c)
                    local c = create_card(nil,G.consumeables, nil, nil, nil, nil, 'c_deja_vu', 'sup')
                    c:add_to_deck()
                    G.consumeables:emplace(c)
                    return true
                end
            }))
        end,
    }
end

-- Borrowed time -1 ante when purchased +1 ante when sold

----------------------------------------------
------------MOD CODE END----------------------