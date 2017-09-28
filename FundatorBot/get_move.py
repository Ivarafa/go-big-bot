import random

def _get_move(ai,map):
    print(map.super_pellets_positions)
    if ai.states.enemy_is_dangerous() and not ai.you.is_dangerous:
        if map.get_manhattan_dist(ai.you.pos, ai.enemy.pos) < 3:
            return run_away(ai, map)
    if (map.super_pellets_positions):
        return go_to_closest_super_pellet(ai, map)
    #elif ai.states.is_monster_present():
     #   return survive_monster(ai,map)
    elif map.pellet_positions:
        return go_to_closest_pellet(ai, map)
    else:
        return random.choice(range(0,4))
    #return map.get_move_between(ai.you.pos, random.choice(list(map._get_available_neighbours(ai.you.pos))))

def go_to_closest_super_pellet(ai, map):
    pellets = list(map.super_pellets_positions)
    for pellet in pellets:
        if map.get_manhattan_dist(ai.enemy.pos, pellet) < map.get_manhattan_dist(ai.you.pos, pellet):
            pellets.remove(pellet)
    if not pellets:
        pellets = list(map.super_pellets_positions)
    best = pellets[0]
    for pellet in pellets:
        if map.get_manhattan_dist(ai.you.pos, pellet) < map.get_manhattan_dist(ai.you.pos, best):
            best = pellet
    return map.get_move_between(ai.you.pos, map.get_astar_path(ai.you.pos, best)[0])

def go_to_closest_pellet(ai, map):
    pellets = list(map.pellet_positions)
    for pellet in pellets:
        if map.get_manhattan_dist(ai.enemy.pos, pellet) < map.get_manhattan_dist(ai.you.pos, pellet):
            pellets.remove(pellet)
    if not pellets:
        pellets = list(map.pellet_positions)
    best = pellets[0]
    for pellet in pellets:
        if map.get_manhattan_dist(ai.you.pos, pellet) < map.get_manhattan_dist(ai.you.pos, best):
            best = pellet
    return map.get_move_between(ai.you.pos, map.get_astar_path(ai.you.pos, best)[0])

def survive_monster(ai, map):
    corners = map.get_corners()
    if ai.you.pos in corners:
        return -1
    best = corners[0]
    for corner in corners:
        if map.get_manhattan_dist(ai.you.pos, corner) < map.get_manhattan_dist(ai.you.pos, best):
            best = corner
    return map.get_move_between(ai.you.pos, map.get_astar_path(ai.you.pos, best)[0])

def run_away(ai, map):
    danger = map.get_astar_path(ai.you.pos, ai.enemy.pos)[0]
    posibilities = list(map._get_available_neighbours(ai.you.pos))
    posibilities.remove(danger)
    posibilities = [map.get_move_between(ai.you.pos, x) for x in posibilities]
    danger_move = map.get_move_between(ai.you.pos, danger)
    if danger_move == 3 and 1 in posibilities:
        return 1
    elif danger_move == 1 and 3 in posibilities:
        return 3
    elif danger_move == 0 and 2 in posibilities:
        return 2
    elif danger_move == 2 and 0 in posibilities:
        return 0
    else:
        return random.choice(posibilities)