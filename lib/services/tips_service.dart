import 'package:minkids/models/tip.dart';

class TipsService {
  // Consejos para padres
  static final List<TipModel> _parentTips = [
    TipModel(
      id: 'p1',
      title: 'Establece límites claros',
      content: 'Define horarios específicos para el uso de dispositivos. Los niños necesitan estructura y consistencia. Ejemplo: 1 hora después de hacer tareas, nada después de las 9 PM.',
      category: 'Límites',
      targetRole: 'padre',
      iconName: 'schedule',
      colorName: 'blue',
    ),
    TipModel(
      id: 'p2',
      title: 'Sé un ejemplo digital',
      content: 'Los niños aprenden observando. Si pasas mucho tiempo en tu teléfono durante las comidas o conversaciones, ellos harán lo mismo. Practica lo que predicas.',
      category: 'Ejemplo',
      targetRole: 'padre',
      iconName: 'person',
      colorName: 'green',
    ),
    TipModel(
      id: 'p3',
      title: 'Conversa sobre lo que ve',
      content: 'Pregunta qué videos ve, qué juegos juega, con quién chatea. No como interrogatorio, sino con genuino interés. Esto fortalece la confianza y te permite detectar riesgos.',
      category: 'Comunicación',
      targetRole: 'padre',
      iconName: 'chat',
      colorName: 'purple',
    ),
    TipModel(
      id: 'p4',
      title: 'Fomenta actividades offline',
      content: 'Promueve deportes, lectura, arte, juegos de mesa. Un niño ocupado y feliz en el mundo real tendrá menos necesidad de escapar al digital.',
      category: 'Equilibrio',
      targetRole: 'padre',
      iconName: 'sports_soccer',
      colorName: 'orange',
    ),
    TipModel(
      id: 'p5',
      title: 'Crea zonas libres de pantallas',
      content: 'Designa espacios sin dispositivos: la mesa del comedor, el dormitorio. Esto fortalece la comunicación familiar y mejora la calidad del sueño.',
      category: 'Espacios',
      targetRole: 'padre',
      iconName: 'no_cell',
      colorName: 'red',
    ),
    TipModel(
      id: 'p6',
      title: 'Enséñale sobre privacidad',
      content: 'Explica que no debe compartir información personal (dirección, escuela, teléfono) con extraños en línea. Usa ejemplos de la vida real para que lo entienda mejor.',
      category: 'Seguridad',
      targetRole: 'padre',
      iconName: 'security',
      colorName: 'indigo',
    ),
    TipModel(
      id: 'p7',
      title: 'Usa recompensas, no solo castigos',
      content: 'En lugar de solo quitar el celular, ofrece tiempo extra por buenas acciones: terminar tareas temprano, ayudar en casa, leer un libro. Esto motiva mejor.',
      category: 'Motivación',
      targetRole: 'padre',
      iconName: 'star',
      colorName: 'amber',
    ),
    TipModel(
      id: 'p8',
      title: 'Monitorea sin espiar',
      content: 'Hay diferencia entre vigilancia y monitoreo saludable. Sé transparente: dile que usas MinKids para su seguridad, no para controlar cada aspecto de su vida.',
      category: 'Confianza',
      targetRole: 'padre',
      iconName: 'visibility',
      colorName: 'teal',
    ),
    TipModel(
      id: 'p9',
      title: 'Identifica señales de adicción',
      content: '¿Irritabilidad sin celular? ¿Descuida amistades? ¿Baja de rendimiento escolar? Estos son signos de alerta. Consulta con un profesional si es necesario.',
      category: 'Salud',
      targetRole: 'padre',
      iconName: 'warning',
      colorName: 'deepOrange',
    ),
    TipModel(
      id: 'p10',
      title: 'Actualiza las reglas según la edad',
      content: 'Un niño de 8 años necesita límites distintos que uno de 14. Revisa y ajusta las restricciones periódicamente. Involúcralo en la conversación conforme crece.',
      category: 'Adaptación',
      targetRole: 'padre',
      iconName: 'update',
      colorName: 'cyan',
    ),
    TipModel(
      id: 'p11',
      title: 'Conoce las apps que usa',
      content: 'Descarga y prueba las apps populares entre niños: TikTok, Instagram, juegos online. Solo así podrás entender los riesgos y configurar la privacidad adecuada.',
      category: 'Conocimiento',
      targetRole: 'padre',
      iconName: 'apps',
      colorName: 'pink',
    ),
    TipModel(
      id: 'p12',
      title: 'Promueve el pensamiento crítico',
      content: 'Enséñale a cuestionar lo que ve: "¿Es real esa foto? ¿Ese influencer está siendo honesto? ¿Ese mensaje podría ser un engaño?" Desarrolla su criterio propio.',
      category: 'Educación',
      targetRole: 'padre',
      iconName: 'psychology',
      colorName: 'deepPurple',
    ),
  ];

  // Consejos para hijos
  static final List<TipModel> _childTips = [
    TipModel(
      id: 'c1',
      title: 'Haz pausas frecuentes',
      content: 'Por cada 30 minutos frente a la pantalla, descansa 5-10 minutos. Estira, mira por la ventana, camina. Tus ojos y tu cuerpo te lo agradecerán.',
      category: 'Salud',
      targetRole: 'hijo',
      iconName: 'self_improvement',
      colorName: 'green',
    ),
    TipModel(
      id: 'c2',
      title: 'Cuidado con extraños en línea',
      content: 'Nunca compartas tu dirección, escuela, teléfono o fotos personales con personas que no conoces en persona. Aunque parezcan amigables, pueden ser peligrosos.',
      category: 'Seguridad',
      targetRole: 'hijo',
      iconName: 'shield',
      colorName: 'red',
    ),
    TipModel(
      id: 'c3',
      title: 'No creas todo lo que ves',
      content: 'Las redes sociales muestran solo lo "perfecto" de la vida de otros. La realidad es diferente. No compares tu día a día con los "highlights" de otros.',
      category: 'Bienestar',
      targetRole: 'hijo',
      iconName: 'sentiment_satisfied',
      colorName: 'purple',
    ),
    TipModel(
      id: 'c4',
      title: 'Habla si algo te incomoda',
      content: 'Si ves algo raro, recibe mensajes extraños, o alguien te hace sentir mal online, cuéntale a un adulto de confianza. No es "acusar", es cuidarte.',
      category: 'Comunicación',
      targetRole: 'hijo',
      iconName: 'record_voice_over',
      colorName: 'orange',
    ),
    TipModel(
      id: 'c5',
      title: 'El mundo real es mejor',
      content: 'Los amigos en persona, los juegos al aire libre, leer un libro... estas cosas hacen tu vida más rica y feliz que cualquier app o videojuego.',
      category: 'Equilibrio',
      targetRole: 'hijo',
      iconName: 'nature_people',
      colorName: 'teal',
    ),
    TipModel(
      id: 'c6',
      title: 'Piensa antes de publicar',
      content: 'Una vez que subes algo a internet, es casi imposible borrarlo completamente. Pregúntate: ¿Esto podría avergonzarme después? ¿Afectaría a otros?',
      category: 'Responsabilidad',
      targetRole: 'hijo',
      iconName: 'lightbulb',
      colorName: 'amber',
    ),
    TipModel(
      id: 'c7',
      title: 'Protege tus contraseñas',
      content: 'No compartas tus contraseñas ni siquiera con "mejores amigos". Usa contraseñas diferentes para cada app y no las dejes escritas donde otros puedan verlas.',
      category: 'Seguridad',
      targetRole: 'hijo',
      iconName: 'lock',
      colorName: 'indigo',
    ),
    TipModel(
      id: 'c8',
      title: 'Sé amable online',
      content: 'Trata a otros en internet como te gustaría ser tratado. No insultes, no te burles, no difundas rumores. El ciberbullying hace mucho daño.',
      category: 'Respeto',
      targetRole: 'hijo',
      iconName: 'favorite',
      colorName: 'pink',
    ),
    TipModel(
      id: 'c9',
      title: 'Tu cerebro necesita variedad',
      content: 'Hacer siempre lo mismo (scrolling infinito) es aburrido para tu cerebro. Prueba hobbies nuevos: música, dibujo, cocina, deportes. ¡Sorpréndete!',
      category: 'Desarrollo',
      targetRole: 'hijo',
      iconName: 'palette',
      colorName: 'cyan',
    ),
    TipModel(
      id: 'c10',
      title: 'Duerme sin pantallas',
      content: 'La luz azul del celular confunde a tu cerebro y te quita el sueño. Deja el celular al menos 1 hora antes de dormir. Dormirás mejor y tendrás más energía.',
      category: 'Descanso',
      targetRole: 'hijo',
      iconName: 'bedtime',
      colorName: 'deepPurple',
    ),
    TipModel(
      id: 'c11',
      title: 'Aprende algo útil online',
      content: 'Internet no es solo para entretenimiento. Usa YouTube para aprender a tocar guitarra, Khan Academy para matemáticas, Duolingo para idiomas. ¡Crece!',
      category: 'Aprendizaje',
      targetRole: 'hijo',
      iconName: 'school',
      colorName: 'blue',
    ),
    TipModel(
      id: 'c12',
      title: 'Cuida tu postura',
      content: 'Sentarte encorvado mirando el celular puede causar dolor de cuello y espalda. Mantén el dispositivo a la altura de los ojos y siéntate derecho.',
      category: 'Salud',
      targetRole: 'hijo',
      iconName: 'accessibility_new',
      colorName: 'green',
    ),
  ];

  /// Obtener consejos según el rol del usuario
  static List<TipModel> getTipsForRole(String role) {
    return role == 'padre' ? _parentTips : _childTips;
  }

  /// Obtener consejo aleatorio para el rol
  static TipModel getRandomTipForRole(String role) {
    final tips = getTipsForRole(role);
    tips.shuffle();
    return tips.first;
  }

  /// Obtener consejos por categoría
  static List<TipModel> getTipsByCategory(String role, String category) {
    final tips = getTipsForRole(role);
    return tips.where((tip) => tip.category == category).toList();
  }

  /// Obtener todas las categorías disponibles para un rol
  static List<String> getCategoriesForRole(String role) {
    final tips = getTipsForRole(role);
    return tips.map((tip) => tip.category).toSet().toList()..sort();
  }
}
