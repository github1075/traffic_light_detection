import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  int _currentPage = 1;
  int _countriesPerPage = 10;
  List<dynamic> _countries = [];

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      'https://countries.trevorblades.com/',
    );

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Country List'),
        ),
        body: Query(
          options: QueryOptions(
            document: gql("""
              query GetCountries {
                countries {
                  name
                }
              }
            """),
          ),
          builder: (QueryResult result, {Refetch? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }

            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            _countries = result.data!['countries'];

            final int startIndex = (_currentPage - 1) * _countriesPerPage;
            final int endIndex = startIndex + _countriesPerPage;
            final displayedCountries = _countries.sublist(startIndex, endIndex.clamp(0, _countries.length));

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedCountries.length,
                    itemBuilder: (BuildContext context, int index) {
                      final country = displayedCountries[index];
                      return ListTile(
                        title: Text(country['name']),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage > 1 ? () => _loadPreviousPage() : null,
                        child: Text('Previous'),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 1; i <= _getTotalPages(); i++)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(12.0),
                                    primary: i == _currentPage ? Colors.blue : null,
                                  ),
                                  onPressed: () => _loadPage(i),
                                  child: Text(i.toString(), style: TextStyle(color: i == _currentPage ? Colors.white : Colors.black)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _currentPage < _getTotalPages() ? () => _loadNextPage() : null,
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _loadPreviousPage() {
    setState(() {
      _currentPage--;
    });
  }

  void _loadNextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _loadPage(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
    });
  }

  int _getTotalPages() {
    return (_countries.length / _countriesPerPage).ceil();
  }
}
