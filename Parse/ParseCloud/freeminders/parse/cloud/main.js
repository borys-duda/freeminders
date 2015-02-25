/// <reference path="../parse.js" />

var _ = require('underscore');

Parse.Object.prototype.setIf = function (key, value, options) {
    if (typeof value !== 'undefined') {
        switch (key) {
            case 'id':
            case 'objectId':
                this.id = value;
                break;
            default:
                this.set(key, value, options);
                break;
        }
    }
}

function ResponseDecoder() {
    this.decodeArr = [];
}

ResponseDecoder.prototype.enqueue = function (o, i) {
    i._ref = o;
    this.decodeArr.push(i);
};

ResponseDecoder.prototype.updateResponse = function () {
    _.each(this.decodeArr, function (a) {
        a.id = a._ref.id;
        delete a._ref;
    })
}

function isNullOrUndefined(value) {
    return (value === null || typeof value === 'undefined');
}

function createItem(className, properties) {
    var objClass = Parse.Object.extend(className);
    var obj = new objClass();
    if (properties) {
        for (var name in properties) {
            if (properties.hasOwnProperty(name)) {
                var val = properties[name];
                obj.setIf(name, val);
            }
        }
    }
    return obj;
}

function updateCommon(item, obj) {
    item['id'] = obj.id;
    item['createdAt'] = obj.createdAt;
    item['updatedAt'] = obj.updatedAt;
}

Parse.Cloud.define("editor_load", function (request, response) {

    // TODO: Validate user is authenticated and retrieve only those valid for the user
    var user = request.user, obj = request.params;
    
    var items = [];
    var groups = [];
    var categories = [];

    editor_loadCategories()
        .then(function (c) {
            categories = c;
            return editor_loadReminderGroups(user);
        })
        .then(function (g) {
            groups = g;
            return editor_loadStoreItems(user);
        })
        .then(
            function (i) {
                items = i;
                response.success({
                    items: items,
                    groups: groups,
                    categories: categories
                });
            },
            function (err) {
                response.error(err);
            }
        );
});

function editor_loadCategories() {

    var promise = new Parse.Promise();

    var catq = new Parse.Query("StoreCategory");
    var categories = null;

    catq
        .find()
        .then(function (cats) {
            categories = _.map(cats, function (cat) {
                return {
                    id: cat.id,
                    //createdAt: cat.createdAt,
                    //updatedAt: cat.updatedAt,
                    name: cat.get('name'),
                    description: cat.get('description')
                }
            });
        })
        .done(function () {
            promise.resolve(categories);
        })
        .fail(function (err) {
            promise.reject(err);
        });
    
    return promise;
}

function editor_loadReminderGroups(user) {

    var promise = new Parse.Promise();

    var query = new Parse.Query("ReminderGroup");
    var groups = [];

    var triggerCommon = function (obj) {
        return {
            id: obj.id,
            //createdAt: obj.createdAt,
            //updatedAt: obj.updatedAt,
            name: obj.get('name'),
            isActive: obj.get('isActive')
        };
    };

    query.equalTo('owner', user);

    query.include("reminders");
    query.include("reminders.reminderSteps");
    query.include("reminders.dateTimeTriggers");
    query.include("reminders.locationTriggers");
    query.include("reminders.weatherTriggers");

    query
        .find()
        .then(function (results) {

            _.each(results || [], function (result) {
                groups.push({
                    id: result.id,
                    //createdAt: result.createdAt,
                    //updatedAt: result.updatedAt,
                    name: result.get('name'),
                    description: result.get('description'),
                    reminders: _.map(result.get('reminders'), function (reminder) {
                        return {
                            id: reminder.id,
                            //createdAt: reminder.createdAt,
                            //updatedAt: reminder.updatedAt,
                            name: reminder.get('name'),
                            note: reminder.get('note'),
                            isActive: reminder.get('isActive'),
                            reminderSteps: _.map(reminder.get('reminderSteps'), function (step) {
                                return {
                                    id: step.id,
                                    //createdAt: step.createdAt,
                                    //updatedAt: step.updatedAt,
                                    name: step.get('name'),
                                    order: step.get('order'),
                                    isComplete: step.get('isComplete')                                    
                                }
                            }),
                            parentReminders: _.map(reminder.get('parentReminders'), function (parent) {
                                return parent.id;
                            }),
                            dateTimeTriggers: _.map(reminder.get('dateTimeTriggers'), function (trig) {
                                var obj = triggerCommon(trig);
                                return obj;
                            }),
                            locationTriggers: _.map(reminder.get('locationTriggers'), function (trig) {
                                var obj = triggerCommon(trig);
                                return obj;
                            }),
                            weatherTriggers: _.map(reminder.get('weatherTriggers'), function (trig) {
                                var obj = triggerCommon(trig);
                                return obj;
                            })
                        };
                    })
                });
            });

        })
        .done(function () {
            promise.resolve(groups);
        })
        .fail(function (err) {
            promise.reject(err);
        });

    return promise;
}

function editor_loadStoreItems(user) {

    var promise = new Parse.Promise();
    var query = new Parse.Query("StoreItem");

    var items = [];

    query
        .find()
        .then(function (results) {

            _.each(results || [], function (result) {
                items.push({
                    id: result.id,
                    //createdAt: result.createdAt,
                    //updatedAt: result.updatedAt,
                    name: result.get('name'),
                    description: result.get('description'),
                    isEnabled: result.get('isEnabled'),
                    unlimitedEmail: result.get('unlimitedEmail'),
                    countEmail: result.get('countEmail'),
                    countSMS: result.get('countSMS'),
                    price: result.get('price'),
                    salePrice: result.get('salePrice'),
                    storeCategories: _.map(result.get('storeCategories'), function (cat) {
                        return cat.id;
                    }),
                    reminderGroups: _.map(result.get('reminderGroups'), function (group) {
                        return group.id;
                    })
                });
            });

        })
        .done(function () {
            promise.resolve(items);
        })
        .fail(function (err) {
            promise.reject(err);
        });

    return promise;
}

Parse.Cloud.define("editor_save", function (request, response) {

    // TODO: Validate user is authenticated
    var user = request.user, obj = request.params;
    var data = obj.data;

    Parse.Promise.as()
        .then(function () { return editor_saveReminderGroups(user, data.groups); })
        .then(function () { return editor_saveStoreItems(user, data.items, data.groups); })
        .then(function () { return editor_destroyItems(user, data.destroy); })
        .then(
            function () {
                delete data.destroy;
                response.success({
                    data: data
                });
            },
            function (err) {
                response.error(err);
            }
        );

});

function editor_saveReminderGroups(user, igroups) {

    var promise = new Parse.Promise();
    var decoder = new ResponseDecoder();

    var triggerCommon = function (type, itrigger, callback) {
        var otrigger = createItem(type, {
            id: itrigger.id,
            name: itrigger.name,
            isActive: itrigger.isActive
        });
        callback(otrigger);
        decoder.enqueue(otrigger, itrigger);
        return otrigger;
    };

    var ogroups = [];
    var oreminders = [];
    var ireminders = [];
    
    _.each(igroups || [], function (igroup) {

        var ogroup = createItem('ReminderGroup', {
            id: igroup.id,
            owner: user,
            name: igroup.name,
            description: igroup.description
        });

        ogroup._reminders = _.map(igroup.reminders || [], function (ireminder) {
            var oreminder = createItem('Reminder', {
                id: ireminder.id,
                name: ireminder.name,
                note: ireminder.note,
                isActive: ireminder.isActive,
                reminderSteps: _.map(ireminder.reminderSteps || [], function (istep) {
                    var ostep = createItem('ReminderStep', {
                        id: istep.id,
                        name: istep.name,
                        order: istep.order,
                        isComplete: istep.isComplete
                    });
                    decoder.enqueue(ostep, istep);
                    return ostep;
                }),
                dateTimeTriggers: _.map(ireminder.dateTimeTriggers || [], function (itrigger) {
                    return triggerCommon('DateTimeTrigger', itrigger, function (otrigger) {
                    });
                }),
                locationTriggers: _.map(ireminder.locationTriggers || [], function (itrigger) {
                    return triggerCommon('LocationTrigger', itrigger, function (otrigger) {
                    });
                }),
                weatherTriggers: _.map(ireminder.weatherTriggers || [], function (itrigger) {
                    return triggerCommon('WeatherTrigger', itrigger, function (otrigger) {
                    });
                }),
                parentReminders: null
            });

            decoder.enqueue(oreminder, ireminder);
            oreminders.push(oreminder);
            ireminders.push(ireminder);

            return oreminder;
        });

        decoder.enqueue(ogroup, igroup);
        ogroups.push(ogroup);
    });

    Parse.Promise.as()
        .then(function () {
            if (oreminders.length)
                return Parse.Object.saveAll(oreminders);
            return Parse.Promise.as();
        })
        .then(function () {

            var map = {}, arr = [];

            // Spin once so we can create a lookup map
            _.each(ireminders || [], function (ireminder) {
                map[ireminder.key] = ireminder._ref;
            });

            // Spin again, this time collecting relationships.  We had to spin above because of potential
            // circular relationships or ordering issues.
            _.each(ireminders || [], function (ireminder) {

                // We want to look at the parent reminders, and find them in the map.  No parents, skip it
                // that means we don't have not stinking parents...
                var parents = ireminder.parentReminders || [];
                if (parents.length) {

                    // Find the already saved parent and add it to our aray of pointers
                    var oreminder = map[ireminder.key];
                    oreminder.set('parentReminders', _.map(parents, function (iparent) {
                        return map[iparent.key];
                    }));

                    // Queue it for the saveAll method below
                    arr.push(oreminder);
                }
            });

            // We have some that have relationships, so we have to save those... *again*
            if (arr.length)
                return Parse.Object.saveAll(arr);

            // Nope, just return an empty promise *empty promise, haha*
            return Parse.Promise.as();

        })
        .then(function () {
            
            _.each(ogroups || [], function (ogroup) {
                ogroup.set('reminders', ogroup._reminders);
                delete ogroup._reminders;
            });

            if (ogroups.length)
                return Parse.Object.saveAll(ogroups);
            return Parse.Promise.as();
        })
        .done(function () {
            decoder.updateResponse();
            promise.resolve(igroups);
        })
        .fail(function (err) {
            promise.reject(err);
        });

    return promise;
};

function editor_saveStoreItems(user, iitems, igroups) {

    var promise = new Parse.Promise();
    var decoder = new ResponseDecoder();

    var mapGroup = {};

    _.each(igroups || [], function(igroup) {
        mapGroup[igroup.key] = igroup.id;
    });

    var oitems = _.map(iitems || [], function (iitem) {

        var oitem = createItem('StoreItem', {
            id: iitem.id,
            name: iitem.name,
            description: iitem.description,
            isEnabled: iitem.isEnabled,
            unlimitedEmail: iitem.unlimitedEmail,
            countEmail: iitem.countEmail,
            countSMS: iitem.countSMS,
            price: iitem.price,
            salePrice: iitem.salePrice,
            reminderGroups: _.map(iitem.reminderGroups || [], function (groupKey) {
                var oreminderGroup = createItem('ReminderGroup', {
                    id: mapGroup[groupKey]
                });
                return oreminderGroup;
            }),
            storeCategories: _.map(iitem.storeCategories || [], function (categoryid) {
                var ocategory = createItem('StoreCategory', {
                    id: categoryid
                });
                return ocategory;
            })
        });

        decoder.enqueue(oitem, iitem);
        return oitem;
    });

    Parse.Promise.as()
        .then(function () {
            if (oitems.length)
                return Parse.Object.saveAll(oitems);
            return Parse.Promise.as();
        })
        .then(
            function () {
                decoder.updateResponse();
                promise.resolve(iitems);
            },
            function (err) {
                promise.reject(err);
            }
        );

    return promise;
};

function editor_destroyItems(user, idestroys) {
    var promise = new Parse.Promise();

    var arr = _.map(idestroys, function (idestroy) {
        return createItem(idestroy.type, {
            id: idestroy.id
        })
    });

    if (arr.length)
        return Parse.Object.destroyAll(arr);
    return Parse.Promise.as();
};