import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/catalog/catalog.controller.dart';
import 'package:flutter_frontend/feature/catalog/dataset.dart';
import 'package:flutter_frontend/feature/filter/filter.controller.dart';
import 'package:flutter_frontend/feature/filter/filter_list.state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterWidget extends ConsumerStatefulWidget {
  final List<Enum> types;
  final String typeName;
  const FilterWidget({super.key, required this.types, required this.typeName});

  @override
  ConsumerState<FilterWidget> createState() {
    return _FilterWidgetState();
  }
}

class _FilterWidgetState extends ConsumerState<FilterWidget> {
  Enum? _selectedEnum;
  Enum? _previousSelectedEnum;

  @override
  Widget build(BuildContext context) {
    final CatalogController catalogController = ref.read(
      catalogControllerProvider.notifier,
    );

    // update Value on Provider
    final filterController = ref.watch(
      filterControllerProvider.notifier,
    );

    final filterListState = ref.watch(filterControllerProvider);
    final catalogState = ref.watch(
      catalogControllerProvider,
    );

    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: DropdownButtonFormField<Enum>(
          initialValue: _selectedEnum,
          decoration: InputDecoration(
            labelText: widget.typeName,
            border: const OutlineInputBorder(),

            // FÜGEN SIE DAS CLEAR-ICON HINZU
            suffixIcon:
                _selectedEnum != null
                    ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      color: Colors.grey.shade600,
                      onPressed: () async {
                        // Wenn der Button geklickt wird:
                        setState(() {
                          _previousSelectedEnum = _selectedEnum;
                          _selectedEnum = null;
                        });

                        await updateFilterList(
                          filterController,
                          filterListState,
                        );
                        print(
                          'query: ${catalogState.searchQuery}; \n - category: ${filterListState.category} \n - dataformat: ${filterListState.dataFormat} \n - accessLevel: ${filterListState.accessLevel} \n - dataSensitivity: ${filterListState.dataSensitivity}',
                        );
                      },
                    )
                    // Zeigt nichts an, wenn kein Wert ausgewählt ist
                    : null,
          ),
          items:
              widget.types
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
          onChanged: (v) async {
            setState(() {
              _previousSelectedEnum = _selectedEnum;
              _selectedEnum = v;
            });
            await updateFilterList(filterController, filterListState);
            print(
              'query: ${catalogState.searchQuery}; \n - category: ${filterListState.category} \n - dataformat: ${filterListState.dataFormat} \n - accessLevel: ${filterListState.accessLevel} \n - dataSensitivity: ${filterListState.dataSensitivity}',
            );
          },
          validator: (v) => v == null ? '${widget.typeName} wählen' : null,
        ),
      ),
    );
  }

  Future<void> updateFilterList(
    FilterController filterController,
    FilterListState filterStates,
  ) async {
    if (_selectedEnum == null) {
      switch (_previousSelectedEnum) {
        case final Category _:
          await filterController.updateFilter(
            category: null,
            accessLevel: filterStates.accessLevel,
            dataFormat: filterStates.dataFormat,
            dataSensitivity: filterStates.dataSensitivity,
          );
        case final DataFormat _:
          await filterController.updateFilter(
            category: filterStates.category,
            accessLevel: filterStates.accessLevel,
            dataFormat: _selectedEnum,
            dataSensitivity: filterStates.dataSensitivity,
          );
        case final AccessLevel _:
          await filterController.updateFilter(
            category: filterStates.category,
            accessLevel: _selectedEnum,
            dataFormat: filterStates.dataFormat,
            dataSensitivity: filterStates.dataSensitivity,
          );
        case final DataSensitivity _:
          await filterController.updateFilter(
            category: filterStates.category,
            accessLevel: filterStates.accessLevel,
            dataFormat: filterStates.dataFormat,
            dataSensitivity: _selectedEnum,
          );
        default:
          print('DEFAULT Val 222');
      }
      return;
    }

    switch (_selectedEnum) {
      case final Category _:
        await filterController.updateFilter(
          category: _selectedEnum,
          accessLevel: filterStates.accessLevel,
          dataFormat: filterStates.dataFormat,
          dataSensitivity: filterStates.dataSensitivity,
        );
      case final DataFormat _:
        await filterController.updateFilter(
          category: filterStates.category,
          accessLevel: filterStates.accessLevel,
          dataFormat: _selectedEnum,
          dataSensitivity: filterStates.dataSensitivity,
        );
      case final AccessLevel _:
        await filterController.updateFilter(
          category: filterStates.category,
          accessLevel: _selectedEnum,
          dataFormat: filterStates.dataFormat,
          dataSensitivity: filterStates.dataSensitivity,
        );
      case final DataSensitivity _:
        await filterController.updateFilter(
          category: filterStates.category,
          accessLevel: filterStates.accessLevel,
          dataFormat: filterStates.dataFormat,
          dataSensitivity: _selectedEnum,
        );
      default:
        print('DEFAULT Val');
    }
  }
}
