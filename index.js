class Player {
    constructor(hp, diety) {
        this.hp = hp;
        this.diety = diety;
    }
}

class AttackCard {
    constructor(title, description, damage) {
        this.title = title;
        this.description = description;
        this.damage = damage;
    }

    attack(target) {
        if (target.reduction >= this.damage) {
            return
        }   
        else {
            target.hp -= this.damage;
            return target.hp;
        }
    }

};

class ReactionCard {
    constructor(title, description, reduction) {
        this.title = title;
        this.description = description;
        this.reduction = reduction;
    }

    react(attack) {
        if (this.title === 'dodge') {
            
        }
    }
}

