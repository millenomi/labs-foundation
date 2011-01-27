package net.infinite_labs.basics;

import java.util.List;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Schema {
	public static class ValidationException extends Exception {
		private static final long serialVersionUID = 2570962632826686237L;

		public ValidationException(String whatHappened) {
			super(whatHappened);
		}

		public ValidationException() {
			super();
		}

		public ValidationException(String message, Throwable cause) {
			super(message, cause);
		}

		public ValidationException(Throwable cause) {
			super(cause);
		}
		
	}

	public static class InvalidAnnotationsException extends RuntimeException {
		private static final long serialVersionUID = 2570962632826686237L;

		public InvalidAnnotationsException(String whatHappened) {
			super(whatHappened);
		}
	}
	
	private static Class<?> boxedClassForClass(Class<?> c) {
		if (c == int.class)
			return Integer.class;
		else if (c == long.class)
			return Long.class;
		else if (c == boolean.class)
			return Boolean.class;
		else if (c == float.class)
			return Float.class;
		else if (c == double.class)
			return Double.class;
		else
			return c;
	}
	
	private final static Object Null = new Object();
	
	private static Object defaultObjectForOptionalAnnotationAndType(Class<?> c, Optional annotation) {
		if (c == int.class)
			return annotation.defaultInt();
		else if (c == long.class)
			return annotation.defaultLong();
		else if (c == boolean.class)
			return annotation.defaultBoolean();
		else if (c == float.class)
			return annotation.defaultFloat();
		else if (c == double.class)
			return annotation.defaultDouble();
		else if (annotation.defaultIsNull())
			return Null;
		else if (c == String.class)
			return annotation.defaultString();
		else
			throw new InvalidAnnotationsException("Interface has an optional annotation that's contradictory -- what value should I use?");
	}
	
	private static boolean isObjectOfExpectedType(Object x, Class<?> cls) {
		return boxedClassForClass(cls).isInstance(x);
	}
	
	@SuppressWarnings("unchecked")
	public static <T> T make(Object source, Class<T> interf) throws ValidationException {
		if (source instanceof byte[]) {
			try {
				source = new String((byte[]) source, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new RuntimeException(e);
			}
		}
		
		if (source instanceof String) {
			try {
				source = new JSONObject((String) source);
			} catch (JSONException e) {
				throw new ValidationException("The value passed in seems not to be valid JSON.", e);
			}
		}
		
		if (!(source instanceof JSONObject))
			throw new ValidationException("The value passed in isn't a JSON object (or convertible to).");
		
		final JSONObject o = (JSONObject) source;
		final HashMap<String, Object> values = new HashMap<String, Object>();
		
		for (Method m : interf.getMethods()) {
			
			String fieldName = m.getName(); // TODO differing field names
			
			Class<?> expectedType = m.getReturnType();
			
			Optional optionalNote = m.getAnnotation(Optional.class);
			boolean isRequired = (optionalNote == null);
			boolean hasValue = o.has(fieldName);
			if (isRequired && !hasValue)
				throw new IllegalArgumentException(); // TODO
			else if (!isRequired && !hasValue) {
				values.put(fieldName, defaultObjectForOptionalAnnotationAndType(expectedType, optionalNote));
				continue;
			}
			
			Object examinedObject = o.opt(fieldName); // we know it will never return null.
			
			if (expectedType == Map.class) {
				
				if (!(examinedObject instanceof JSONObject))
					throw new ValidationException("Key " + fieldName + " has a value " + examinedObject + " of invalid value (expected a JSON object (map).)");
				
				JSONObject examinedJSONObject = (JSONObject) examinedObject;
				Iterator<String> i = examinedJSONObject.keys();
				
				Contains containsNote = m.getAnnotation(Contains.class);
				
				HashMap<String, Object> submap = new HashMap<String, Object>();
				while (i.hasNext()) {
					String submapKey = (String) i.next();
					Object submapValue = examinedJSONObject.opt(submapKey); // we know it will never return null.
					
					boolean isPayload = containsNote.value().isInterface();
					if (isPayload) {
						try {
							submap.put(submapKey, Schema.make(submapValue, containsNote.value()));
						} catch (ValidationException e) {
							throw new ValidationException("Array of key " + fieldName + " contains a value that does not validate as a payload required by @Contents " + containsNote.value(), e);
						}
						
					} else if (containsNote != null) {
						if (!isObjectOfExpectedType(submapValue, containsNote.value()))
							throw new ValidationException("Map of key " + fieldName + " contains a value " + examinedObject + " which is not of the @Contains-mandated type " + containsNote.value());

						submap.put(submapKey, submapValue); 
					}
					
				}
				
				values.put(fieldName, submap);
				
			} else if (expectedType == List.class) {
				
				if (!(examinedObject instanceof JSONArray))
					throw new ValidationException("Key " + fieldName + " has a value " + examinedObject + " of invalid value (expected a JSON array.)");
				
				JSONArray examinedJSONArray = (JSONArray) examinedObject;
				
				Contains containsNote = m.getAnnotation(Contains.class);
				
				ArrayList<Object> sublist = new ArrayList<Object>();
				for (int i = 0; i < examinedJSONArray.length(); i++) {
					Object sublistValue = examinedJSONArray.opt(i); // we know it will never return null.
					
					if (containsNote != null) {
						boolean isPayload = containsNote.value().isInterface();
						if (isPayload) {
							try {
								sublist.add(Schema.make(sublistValue, containsNote.value()));
							} catch (ValidationException e) {
								throw new ValidationException("Array of key " + fieldName + " contains a value that does not validate as a payload required by @Contents " + containsNote.value(), e);
							}
							
						} else {
							if (!isObjectOfExpectedType(sublistValue, containsNote.value()))
								throw new ValidationException("Array of key " + fieldName + " contains a value " + examinedObject + " which is not of the @Contains-mandated type " + containsNote.value());
							
							sublist.add(sublistValue);							
						}
					}
					
				}
				
				values.put(fieldName, sublist);
				
			} else if (expectedType.isInterface()) {
				
				try {
					values.put(fieldName, make(examinedObject, expectedType));
				} catch (ValidationException e) {
					throw new ValidationException("Payload of key " + fieldName + " failed validation.", e);
				}
				
			} else {
				if (!isObjectOfExpectedType(examinedObject, expectedType))
					throw new ValidationException("Key " + fieldName + " has a value " + examinedObject + " of invalid type (expected: " + expectedType + ")");

				values.put(fieldName, examinedObject);
			}
			
		}
		
		return (T) Proxy.newProxyInstance(interf.getClassLoader(), new Class<?>[] { interf }, new InvocationHandler() {
			
			@Override
			public Object invoke(Object self, Method method, Object[] args)
					throws Throwable {
				
				String name = method.getName();
				Object returnValue = values.get(name);
				
				if (returnValue == Null)
					returnValue = null;
				
				return returnValue;
				
			}
		});
	}
}
