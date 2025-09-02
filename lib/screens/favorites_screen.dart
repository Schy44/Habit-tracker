import 'package:flutter/material.dart';
import 'package:mytracker/models/quote_model.dart';
import 'package:mytracker/providers/auth_provider.dart';
import 'package:mytracker/providers/quote_provider.dart';
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_styles.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/widgets/empty_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // For Clipboard

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch favorite quotes when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteProvider>(context, listen: false).fetchFavoriteQuotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
      ),
      body: quoteProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quoteProvider.favoriteQuotes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.format_quote, size: 64, color: AppColors.textHint),
                        const SizedBox(height: AppStyles.md),
                        Text(
                          'No favorite quotes yet. Add some from the home screen!',
                          style: AppTypography.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppStyles.md),
                  itemCount: quoteProvider.favoriteQuotes.length,
                  itemBuilder: (context, index) {
                    final quote = quoteProvider.favoriteQuotes[index];
                    return _buildQuoteCard(context, quote, user?.uid, quoteProvider);
                  },
                ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, Quote quote, String? userId, QuoteProvider quoteProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.md),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest, // Use a distinct surface color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium)),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${quote.content}"',
              style: AppTypography.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: AppStyles.sm),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '— ${quote.author}',
                style: AppTypography.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)), // Increased opacity
              ),
            ),
            const SizedBox(height: AppStyles.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '"${quote.content}" - ${quote.author}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quote copied to clipboard!')), 
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    if (userId != null) {
                      await quoteProvider.removeFavoriteQuote(userId, quote.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed \'${quote.content}\' from favorites')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}