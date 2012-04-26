// Generated by IcedCoffeeScript 1.2.0t
(function() {
  var dummyArtwork, frontPage, iced, trendingLocations, __iced_k, __iced_k_noop,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  iced = {
    Deferrals: (function() {

      function _Class(_arg) {
        this.continuation = _arg;
        this.count = 1;
        this.ret = null;
      }

      _Class.prototype._fulfill = function() {
        if (!--this.count) return this.continuation(this.ret);
      };

      _Class.prototype.defer = function(defer_params) {
        var _this = this;
        ++this.count;
        return function() {
          var inner_params, _ref;
          inner_params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          if (defer_params != null) {
            if ((_ref = defer_params.assign_fn) != null) {
              _ref.apply(null, inner_params);
            }
          }
          return _this._fulfill();
        };
      };

      return _Class;

    })(),
    findDeferral: function() {
      return null;
    }
  };
  __iced_k = __iced_k_noop = function() {};

  frontPage = (function() {

    frontPage.name = 'frontPage';

    frontPage.prototype.userLocation = null;

    frontPage.prototype.savedLocations = [];

    function frontPage() {
      var data, doLocation, self, url, ___iced_passed_deferral, __iced_deferrals, __iced_k,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      this.downloadRoom = __bind(this.downloadRoom, this);

      this.getRoomDetails = __bind(this.getRoomDetails, this);

      this.backClicked = __bind(this.backClicked, this);

      self = this;
      (function(__iced_k) {
        __iced_deferrals = new iced.Deferrals(__iced_k, {
          parent: ___iced_passed_deferral,
          filename: "/Users/alastair/Spotify/DynamicJukebox/_js/frontpage.iced",
          funcname: "frontPage"
        });
        $.getJSON(baseUrl + "me.json?user[fb_id]=" + fBook.userData.id, __iced_deferrals.defer({
          assign_fn: (function() {
            return function() {
              return data = arguments[0];
            };
          })(),
          lineno: 6
        }));
        __iced_deferrals._fulfill();
      })(function() {
        (function(__iced_k) {
          if (data === null) {
            url = "users/new?user[fb][access_token]={1}&user[fb][key]={2}&user[fb][token_expires_at]={3}".replace("{1}", fBook.accessToken).replace("{2}", fBook.userData.id).replace("{3}", fBook.timeToExpiry);
            data = {
              "user[fb][access_token]": fBook.accessToken,
              "&user[fb][key]": fBook.userData.id,
              "user[fb][token_expires_at]": fBook.timeToExpiry
            };
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "/Users/alastair/Spotify/DynamicJukebox/_js/frontpage.iced",
                funcname: "frontPage"
              });
              $.post(baseUrl + "users", data, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return data = arguments[0];
                  };
                })(),
                lineno: 19
              }));
              __iced_deferrals._fulfill();
            })(function() {
              return __iced_k(console.log(data));
            });
          } else {
            return __iced_k();
          }
        })(function() {
          if (data.room_id) console.log("joining");
          $("#listenSearch").css("display", "block");
          _this.map = new BrandedMap($("#frontpageMap"));
          $("#txtLocation").bind("keyup", function() {
            return self.locationKeyPress(this);
          });
          _this.setTrendingLocations(trendingLocations);
          doLocation = function() {
            var data, ___iced_passed_deferral2, __iced_deferrals, __iced_k;
            __iced_k = __iced_k_noop;
            ___iced_passed_deferral2 = iced.findDeferral(arguments);
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral2,
                filename: "/Users/alastair/Spotify/DynamicJukebox/_js/frontpage.iced",
                funcname: "doLocation"
              });
              fBook.doRequest("me/?fields=location", __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return data = arguments[0];
                  };
                })(),
                lineno: 37
              }));
              __iced_deferrals._fulfill();
            })(function() {
              if (data.location) {
                (function(__iced_k) {
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral2,
                    filename: "/Users/alastair/Spotify/DynamicJukebox/_js/frontpage.iced",
                    funcname: "doLocation"
                  });
                  fBook.doRequest("/" + data.location.id, __iced_deferrals.defer({
                    assign_fn: (function() {
                      return function() {
                        return data = arguments[0];
                      };
                    })(),
                    lineno: 39
                  }));
                  __iced_deferrals._fulfill();
                })(function() {
                  return __iced_k(_this.userLocation = {
                    lat: data.location.latitude,
                    lng: data.location.longitude
                  });
                });
              } else {
                return __iced_k();
              }
            });
          };
          doLocation();
          $("#olSearch, #olTrending").delegate("li", "click", function() {
            return self.locationClicked(this);
          });
          $("#btnJoinRoom").click(function() {
            return self.joinRoom(_this.currentRoom);
          });
          $("#btnBack").click(_this.backClicked);
          $(window).bind("resize", _this.onResize);
          return _this.onResize();
        });
      });
    }

    frontPage.prototype.onResize = function() {
      var offset;
      offset = $("#divTrending").offset();
      return $("#olTrending, #olSearch").css({
        height: $(window).height() - offset.top - 30
      });
    };

    frontPage.prototype.locationKeyPress = function(el) {
      var completeFunc, rightNow, searchUrl,
        _this = this;
      if ($(el).val().length < 3) {
        $("#divTrending").show();
        $("#divSearch").hide();
        return;
      }
      searchUrl = baseUrl + "room/find.json?q=" + $(el).val() + "&user[fb_id]=" + fBook.userData.id;
      if (this.userLocation) {
        searchUrl += "&center=" + this.userLocation.lat + "," + this.userLocation.lng;
      }
      rightNow = new Date().valueOf();
      completeFunc = function(dateSent) {
        return function(data) {
          var loc, nameArray;
          if (_this.lastDateDisplayed && _this.lastDateDisplayed > dateSent) {
            return;
          }
          _this.lastDateDisplayed = dateSent;
          _this.setSearchLocations(data.rooms);
          return nameArray = (function() {
            var _i, _len, _ref, _results;
            _ref = data.rooms;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              loc = _ref[_i];
              if (!this.savedLocations[loc.fb_id]) {
                this.savedLocations[loc.fb_id] = loc;
              }
              _results.push(loc);
            }
            return _results;
          }).call(_this);
        };
      };
      if (this.currentKeyTimer) clearTimeout(this.currentKeyTimer);
      return this.currentKeyTimer = setTimeout(function() {
        return $.getJSON(searchUrl, null, completeFunc(rightNow));
      }, 500);
    };

    frontPage.prototype.backClicked = function() {
      var targetLatLng;
      $("#frontpageMap").css("-webkit-transform", "rotate(-15deg)");
      targetLatLng = this.map.adjustLatLng(new L.LatLng(51.505, -0.09), 3);
      this.map.map.removeLayer(this.currentmarker);
      this.map.map.setView(targetLatLng, 3);
      return $("#roomdetails").css("right", -527);
    };

    frontPage.prototype.locationClicked = function(el) {
      var loc, targetLatLng;
      loc = this.savedLocations[$(el).attr("data-id")];
      targetLatLng = new L.LatLng(loc.location.latitude, loc.location.longitude);
      this.map.map.setView(this.map.adjustForResults(targetLatLng, 12), 12);
      $("#frontpageMap").css("-webkit-transform", "rotate(0deg)");
      this.map.map.setView(this.map.adjustForResults(targetLatLng, 12), 12);
      if (this.currentmarker) {
        this.map.map.removeLayer(this.currentmarker);
        $("#roomdetails").css("right", -527);
      }
      this.currentmarker = new L.Marker(targetLatLng);
      this.map.map.addLayer(this.currentmarker);
      return this.getRoomDetails(loc.fb_id);
    };

    frontPage.prototype.getRoomDetails = function(locid) {
      var _this = this;
      this.downloadRoom(locid, function(data) {
        var art, divs, i, _i;
        divs = [];
        _this.currentRoom = data;
        $("#roomdetails div.art").remove();
        for (i = _i = 0; _i <= 7; i = ++_i) {
          art = getRandomArtwork().replace("_200", "_100");
          divs.push("<div class='art' style='background-image:url(" + art + ")'/>");
        }
        $("#roomdetails .roomart").append(divs.join(""));
        return $("#roomdetails h1").html(data.name);
      });
      return $("#roomdetails").css("right", 0);
    };

    frontPage.prototype.downloadRoom = function(locid, retFunc) {
      return retFunc(this.savedLocations[locid]);
    };

    frontPage.prototype.joinRoom = function(room, instant) {
      var data,
        _this = this;
      data = {
        'user[fb_id]': fBook.userData.id
      };
      if (room.id) {
        data.room_id = room.id;
      } else {
        data.fb_id = room.fb_id;
      }
      $.getJSON(baseUrl + "room/join.json", data, function(ret) {
        console.log(ret);
        if (instant) {
          return new Room(ret);
        } else {
          return setTimeout(function() {
            return new Room(ret);
          }, 500);
        }
      });
      if (!instant) {
        this.map.map.removeLayer(this.currentmarker);
        $("#roomdetails").css("right", -527);
        $("#listenSearch").css("left", -460);
        return $("#frontpageMap").css("-webkit-transform", "scale(80)");
      }
    };

    frontPage.prototype.setSearchLocations = function(locs) {
      var li, loc, locString, _i, _len, _results;
      $("#olSearch").empty();
      $("#divTrending").hide();
      $("#divSearch").show();
      _results = [];
      for (_i = 0, _len = locs.length; _i < _len; _i++) {
        loc = locs[_i];
        console.log(loc);
        li = $("<li data-id='" + loc.fb_id + "'/>");
        locString = "";
        if (loc.location.street) locString = loc.location.street;
        if (!loc.location.city) continue;
        li.append("<h4 class='loctitle'>" + loc.name + "<span>, " + locString + "</span></h4>");
        li.append("<p>" + loc.location.city + ", " + loc.location.country + "</p>");
        _results.push($("#olSearch").append(li));
      }
      return _results;
    };

    frontPage.prototype.setTrendingLocations = function(locs) {
      var artwork, i, imgSrc, imgUrl, li, loc, locid, numInRoom, people, peopleAdded, peopleDiv, person, ___iced_passed_deferral, __iced_deferrals, __iced_k, _i, _k, _keys, _ref, _results, _while,
        _this = this;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      _ref = locs;
      _keys = (function() {
        var _results2;
        _results2 = [];
        for (_k in _ref) {
          _results2.push(_k);
        }
        return _results2;
      })();
      _i = 0;
      _results = [];
      _while = function(__iced_k) {
        var _break, _continue, _j, _next;
        _break = function() {
          return __iced_k(_results);
        };
        _continue = function() {
          ++_i;
          return _while(__iced_k);
        };
        _next = function(__iced_next_arg) {
          _results.push(__iced_next_arg);
          return _continue();
        };
        if (!(_i < _keys.length)) {
          return _break();
        } else {
          locid = _keys[_i];
          loc = _ref[locid];
          _this.savedLocations[locid] = loc;
          li = $("<li data-id='" + locid + "'/>");
          artwork = $("<div class='albumart'/>");
          for (i = _j = 0; _j <= 3; i = ++_j) {
            imgUrl = getRandomArtwork().replace("_200.jpg", "_50.jpg");
            imgSrc = "<img src='" + imgUrl + "'/>";
            artwork.append(imgSrc);
          }
          li.append(artwork);
          li.append("<h4 class='loctitle'>" + loc.name + "<span>, " + loc.location.city + "</span></h4>");
          numInRoom = Math.round(Math.random() * 50);
          peopleDiv = $("<div class='numpeople'><p>" + numInRoom + " people</p></div>");
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "/Users/alastair/Spotify/DynamicJukebox/_js/frontpage.iced",
              funcname: "frontPage.setTrendingLocations"
            });
            getRandomPeople(9, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  return people = arguments[0];
                };
              })(),
              lineno: 184
            }));
            __iced_deferrals._fulfill();
          })(function() {
            var _l, _len;
            peopleAdded = 0;
            for (_l = 0, _len = people.length; _l < _len; _l++) {
              person = people[_l];
              peopleAdded++;
              if (peopleAdded > numInRoom) break;
              if (!person) continue;
              peopleDiv.append("<img src='" + person.picture + "'/>");
            }
            if (peopleAdded < numInRoom) {
              peopleDiv.append("<p>(+" + (numInRoom - 10) + " more)");
            }
            li.append(peopleDiv);
            return _next($("#olTrending").append(li));
          });
        }
      };
      _while(__iced_k);
    };

    return frontPage;

  })();

  trendingLocations = {
    1: {
      id: 1,
      fb_id: 1,
      location: {
        latitude: 51.54528,
        longitude: 0.00444,
        city: "London, UK"
      },
      name: "Olympics Aquatic Centre",
      users: [
        {
          id: "4f89f09f2f28e61091000001",
          fb_id: "509108009",
          last_room_action_at: "2012-04-15T14:49:00Z",
          first_name: null,
          last_name: null,
          weight: 1
        }
      ]
    },
    2: {
      id: 2,
      fb_id: 2,
      location: {
        latitude: 51.54528,
        longitude: 0.00444,
        city: "London, UK"
      },
      name: "Olympics Stadium"
    }
  };

  window.getRandomPeople = function(num, retFunc) {
    var friends, rand, retArray, ___iced_passed_deferral, __iced_deferrals, __iced_k,
      _this = this;
    __iced_k = __iced_k_noop;
    ___iced_passed_deferral = iced.findDeferral(arguments);
    (function(__iced_k) {
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "/Users/alastair/Spotify/DynamicJukebox/_js/frontpage.iced",
        funcname: "getRandomPeople"
      });
      fBook.getFriends(__iced_deferrals.defer({
        assign_fn: (function() {
          return function() {
            return friends = arguments[0];
          };
        })(),
        lineno: 230
      }));
      __iced_deferrals._fulfill();
    })(function() {
      retArray = [];
      while (retArray.length < num) {
        rand = Math.round(Math.random() * friends.length);
        retArray.push(friends[rand]);
      }
      return retFunc(retArray);
    });
  };

  window.getRandomArtwork = function() {
    var rand;
    rand = Math.round(Math.random() * dummyArtwork.length);
    return dummyArtwork[rand];
  };

  dummyArtwork = ["http://cdn.7static.com/static/img/sleeveart/00/003/865/0000386518_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/013/621/0001362119_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/006/970/0000697091_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/012/291/0001229189_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/012/583/0001258320_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/002/118/0000211849_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/003/912/0000391287_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/653/0001065372_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/649/0001064932_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/652/0001065222_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063789_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/635/0001063527_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058978_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058967_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058926_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/008/516/0000851676_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/398/0000039895_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/398/0000039895_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/768/0000576858_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058967_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058926_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058978_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058978_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/212/0000021283_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/121/0000012142_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/312/0000031237_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/454/0000045472_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058926_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/014/927/0001492721_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099624_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/996/0001099607_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/654/0001065473_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/502/0000550241_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431292_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431297_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405065_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/009/0000000975_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431297_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/010/0000001036_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/050/0000405019_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/502/0000550245_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/502/0000550245_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/005/0000000575_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/011/931/0001193196_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431297_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/312/0000431292_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/004/878/0000487877_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059034_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/242/0000024279_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/007/443/0000744308_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/367/0000036753_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/101/0000010162_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/333/0000533382_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/608/0000560871_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/002/790/0000279046_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/842/0001084277_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/000/102/0000010254_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/013/928/0001392819_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/003/394/0000339455_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/589/0001058967_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/006/354/0000635406_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/006/354/0000635406_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/006/354/0000635406_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/654/0001065473_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/654/0001065460_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/008/203/0000820329_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/005/753/0000575307_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/014/833/0001483374_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059003_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/637/0001063764_200.jpg", "http://cdn.7static.com/static/img/sleeveart/00/010/590/0001059073_200.jpg"];

  window.FrontPage = frontPage;

}).call(this);
