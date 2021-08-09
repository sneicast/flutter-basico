import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/popular_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = 'f58129231efff828be8fc55df2052380';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  MoviesProvider() {
    this.getInDisplayMoview();
    this.getpopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    var url = Uri.https(
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
}
