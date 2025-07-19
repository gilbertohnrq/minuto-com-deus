import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../domain/entities/devotional.dart';
import '../../../domain/entities/reflection.dart';
import '../../providers/reflection_streak_provider.dart';
import '../common/custom_text_field.dart';
import '../common/loading_widget.dart';
import 'streak_animation_widget.dart';

class DevotionalCardWithReflection extends ConsumerStatefulWidget {
  final Devotional devotional;
  final Reflection? existingReflection;
  final VoidCallback? onRefresh;

  const DevotionalCardWithReflection({
    super.key,
    required this.devotional,
    this.existingReflection,
    this.onRefresh,
  });

  @override
  ConsumerState<DevotionalCardWithReflection> createState() =>
      _DevotionalCardWithReflectionState();
}

class _DevotionalCardWithReflectionState
    extends ConsumerState<DevotionalCardWithReflection> {
  late TextEditingController _reflectionController;
  final FocusNode _reflectionFocusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _reflectionController = TextEditingController(
      text: widget.existingReflection?.content ?? '',
    );
    _isExpanded = widget.existingReflection != null;
  }

  @override
  void didUpdateWidget(DevotionalCardWithReflection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingReflection?.content != oldWidget.existingReflection?.content) {
      _reflectionController.text = widget.existingReflection?.content ?? '';
      _isExpanded = widget.existingReflection != null;
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _reflectionFocusNode.dispose();
    super.dispose();
  }

  void _submitReflection() {
    final content = _reflectionController.text.trim();
    if (content.isNotEmpty) {
      ref.read(reflectionStreakNotifierProvider.notifier)
          .submitReflection(widget.devotional.id, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // Responsive padding and sizing
    final cardMargin = EdgeInsets.all(isTablet ? 24.0 : 16.0);
    final cardPadding = EdgeInsets.all(isTablet ? 28.0 : 20.0);
    final iconSize = isTablet ? 24.0 : 20.0;

    final reflectionState = ref.watch(reflectionStreakNotifierProvider);
    final shouldShowAnimation = ref.watch(shouldShowStreakAnimationProvider);

    return Stack(
      children: [
        Container(
          margin: cardMargin,
          child: Card(
            elevation: isTablet ? 6 : 4,
            shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Devocional de Hoje',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: isTablet ? 14 : 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app_date_utils.DateUtils.formatDateDisplay(
                                    widget.devotional.date),
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 20 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onRefresh != null)
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: widget.onRefresh,
                              icon: Icon(
                                Icons.refresh,
                                color: colorScheme.primary,
                                size: iconSize,
                              ),
                              tooltip: 'Atualizar',
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 24 : 16),

                    // Biblical verse section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer.withValues(alpha: 0.4),
                            colorScheme.primaryContainer.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_quote,
                                color: colorScheme.primary,
                                size: iconSize,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Versículo',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Text(
                            widget.devotional.verse,
                            style: textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              color: colorScheme.onSurface,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 28 : 20),

                    // Reflection message section
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: iconSize,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reflexão',
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 8),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 4 : 2,
                        horizontal: isTablet ? 8 : 4,
                      ),
                      child: Text(
                        widget.devotional.message,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: colorScheme.onSurface,
                          fontSize: isTablet ? 16 : 14,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    SizedBox(height: isTablet ? 24 : 16),

                    // Personal reflection section
                    _buildReflectionSection(context, isTablet, reflectionState),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Streak animation overlay
        if (shouldShowAnimation)
          StreakAnimationWidget(
            onAnimationComplete: () {
              ref.read(reflectionStreakNotifierProvider.notifier)
                  .clearStreakAnimation();
            },
          ),
      ],
    );
  }

  Widget _buildReflectionSection(
    BuildContext context,
    bool isTablet,
    ReflectionStreakState reflectionState,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final iconSize = isTablet ? 24.0 : 20.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: colorScheme.secondary,
                      size: iconSize,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sua Reflexão',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
                if (!_isExpanded && widget.existingReflection == null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isExpanded = true;
                      });
                      _reflectionFocusNode.requestFocus();
                    },
                    icon: Icon(
                      Icons.add,
                      size: isTablet ? 20 : 16,
                    ),
                    label: Text(
                      'Adicionar',
                      style: TextStyle(fontSize: isTablet ? 14 : 12),
                    ),
                  ),
              ],
            ),

            SizedBox(height: isTablet ? 12 : 8),

            // Show existing reflection or input field
            if (widget.existingReflection != null && !_isExpanded)
              _buildExistingReflection(context, isTablet)
            else if (_isExpanded)
              _buildReflectionInput(context, isTablet, reflectionState)
            else
              _buildReflectionPrompt(context, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingReflection(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            widget.existingReflection!.content,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.5,
              fontSize: isTablet ? 15 : 13,
            ),
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reflexão salva',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
                fontSize: isTablet ? 12 : 10,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = true;
                });
                _reflectionFocusNode.requestFocus();
              },
              child: Text(
                'Editar',
                style: TextStyle(fontSize: isTablet ? 12 : 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReflectionInput(
    BuildContext context,
    bool isTablet,
    ReflectionStreakState reflectionState,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _reflectionController,
          focusNode: _reflectionFocusNode,
          hintText: 'Compartilhe seus pensamentos sobre esta reflexão...',
          maxLines: 4,
          maxLength: 1000,
          enabled: !reflectionState.isSubmitting,
          validator: (value) {
            return ref.read(reflectionStreakNotifierProvider.notifier)
                .validateContent(value ?? '');
          },
        ),
        
        if (reflectionState.errorMessage != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            reflectionState.errorMessage!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
              fontSize: isTablet ? 12 : 10,
            ),
          ),
        ],

        SizedBox(height: isTablet ? 16 : 12),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isExpanded && widget.existingReflection == null)
              TextButton(
                onPressed: reflectionState.isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _isExpanded = false;
                          _reflectionController.clear();
                        });
                      },
                child: Text(
                  'Cancelar',
                  style: TextStyle(fontSize: isTablet ? 14 : 12),
                ),
              ),
            
            SizedBox(width: isTablet ? 12 : 8),
            
            ElevatedButton.icon(
              onPressed: reflectionState.isSubmitting
                  ? null
                  : _submitReflection,
              icon: reflectionState.isSubmitting
                  ? SizedBox(
                      width: isTablet ? 16 : 14,
                      height: isTablet ? 16 : 14,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      widget.existingReflection != null
                          ? Icons.update
                          : Icons.send,
                      size: isTablet ? 18 : 16,
                    ),
              label: Text(
                reflectionState.isSubmitting
                    ? 'Salvando...'
                    : widget.existingReflection != null
                        ? 'Atualizar'
                        : 'Salvar Reflexão',
                style: TextStyle(fontSize: isTablet ? 14 : 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReflectionPrompt(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: colorScheme.secondary.withValues(alpha: 0.7),
            size: isTablet ? 32 : 28,
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Adicione sua reflexão pessoal sobre este devocional',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isTablet ? 13 : 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}