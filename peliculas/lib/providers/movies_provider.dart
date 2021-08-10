import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/popular_response.dart';
import 'package:peliculas/models/search_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = 'f58129231efff828be8fc55df2052380';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      this._suggestionStreamController.stream;

  MoviesProvider() {
    this.getInDisplayMoview();
    this.getpopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(
      this._baseUrl,
      endpoint,
      {
        'api_key': _apiKey,
        'language': _language,
        'page': '$page',
      },
    );

    final response = await http.get(url);
    return response.body;
  }

  getInDisplayMoview() async {
    final jsonData = await this._getJsonData('/3/movie/now_playing');

    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getpopularMovies() async {
    this._popularPage++;
    final jsonData = await this._getJsonData(
      '/3/movie/popular',
      this._popularPage,
    );

    final popularResponse = PopularResponse.fromJson(jsonData);
    this.popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    print('Pidiendo info al servidor');
    final jsonData = await this._getJsonData('/3/movie/$movieId/credits');
    final creditsresponse = CreditsResponse.fromJson(jsonData);
    moviesCast[movieId] = creditsresponse.cast;

    return creditsresponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(
      this._baseUrl,
      '/3/search/movie',
      {
        'api_key': _apiKey,
        'language': _language,
        'query': '$query',
      },
    );

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      //print('Tenemos valor a buscar $value');
      final results = await this.searchMovies(value);
      this._suggestionStreamController.add(results);
    };
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
