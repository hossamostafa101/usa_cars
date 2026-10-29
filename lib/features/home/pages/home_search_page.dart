import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../marketplace/data/models/product_model.dart';
import '../../marketplace/data/services/marketplace_api_service.dart';
import '../../marketplace/page/product_details_page.dart';

class HomeSearchPage extends StatefulWidget {
  final bool startVoice;

  const HomeSearchPage({
    super.key,
    this.startVoice = false,
  });

  @override
  State<HomeSearchPage> createState() =>
      _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  static const orange = Color(0xFFF57C00);
  static const ink = Color(0xFF172033);

  final TextEditingController searchController =
  TextEditingController();

  final MarketplaceApiService api =
  MarketplaceApiService();

  final stt.SpeechToText speech =
  stt.SpeechToText();

  List<ProductModel> results = [];

  bool isSearching = false;
  bool hasSearched = false;
  bool speechAvailable = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final available = await speech.initialize(
      onStatus: (_) {
        if (mounted) {
          setState(() {});
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );

    if (!mounted) return;

    setState(() {
      speechAvailable = available;
    });

    if (available && widget.startVoice) {
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (mounted) {
        await _startVoiceSearch();
      }
    }
  }

  Future<void> _search(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        results = [];
        hasSearched = false;
        errorMessage = null;
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      isSearching = true;
      hasSearched = true;
      errorMessage = null;
    });

    try {
      final data = await api.getProducts(
        search: query,
        perPage: 40,
      );

      if (!mounted) return;

      setState(() {
        results = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        results = [];
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  Future<void> _startVoiceSearch() async {
    if (!speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voice search is not available on this device.',
          ),
        ),
      );
      return;
    }

    if (speech.isListening) {
      await speech.stop();

      if (mounted) {
        setState(() {});
      }

      return;
    }

    await speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.trim();

        if (!mounted) return;

        searchController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
            offset: text.length,
          ),
        );

        setState(() {});

        if (result.finalResult && text.isNotEmpty) {
          _search(text);
        }
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: !widget.startVoice,
                    textInputAction:
                    TextInputAction.search,
                    onSubmitted: _search,
                    decoration: InputDecoration(
                      hintText:
                      'Search parts, tires or brands',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                      ),
                      suffixIcon:
                      searchController.text.isEmpty
                          ? null
                          : IconButton(
                        onPressed: () {
                          searchController
                              .clear();

                          setState(() {
                            results = [];
                            hasSearched =
                            false;
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                      filled: true,
                      fillColor:
                      const Color(0xFFF5F6F8),
                      contentPadding:
                      EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Material(
                  color: speech.isListening
                      ? orange
                      : const Color(0xFFFFF0E1),
                  borderRadius:
                  BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _startVoiceSearch,
                    borderRadius:
                    BorderRadius.circular(14),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        speech.isListening
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_none_rounded,
                        color: speech.isListening
                            ? Colors.white
                            : orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!hasSearched) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.manage_search_rounded,
                size: 55,
                color: Color(0xFFB0B6C0),
              ),
              SizedBox(height: 12),
              Text(
                'Search your marketplace',
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Find parts, tires and brands.',
                style: TextStyle(
                  color: Color(0xFF8D94A0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No matching products found.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 9),
      itemBuilder: (_, index) {
        return _SearchProductTile(
          product: results[index],
        );
      },
    );
  }
}

class _SearchProductTile extends StatelessWidget {
  final ProductModel product;

  const _SearchProductTile({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: product.id == null
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailsPage(
                    productId: product.id!,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFFFF3E8),
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                      _fallback(),
                )
                    : _fallback(),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                        Color(0xFF172033),
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      product.brand ??
                          (product.isTire
                              ? 'Tire'
                              : 'Car part'),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                        Color(0xFF8B929D),
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color:
                        Color(0xFFF57C00),
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFA6ACB5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Icon(
      product.isTire
          ? Icons.tire_repair_rounded
          : Icons.build_rounded,
      color: const Color(0xFFF57C00),
    );
  }
}